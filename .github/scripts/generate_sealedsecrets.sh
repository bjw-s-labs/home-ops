#!/bin/bash
REPO_ROOT=$(git rev-parse --show-toplevel)
CLUSTER_ROOT="${REPO_ROOT}/deployments"
SECRETS_ROOT="${REPO_ROOT}/.secrets"
TEMPLATES_ROOT="${REPO_ROOT}/.templates"
CLUSTER_VARS="${SECRETS_ROOT}/cluster-vars.yaml"
PUB_CERT="${REPO_ROOT}/_setup/sealedsecret-cert.pem"

need() {
    which "$1" &>/dev/null || die "Binary '$1' is missing but required"
}

need "kubectl"
need "kubeval"
need "renderizer"
need "yq"

message() {
  echo -e "\n######################################################################"
  echo "# $1"
  echo "######################################################################"
}

[ -f "${CLUSTER_VARS}" ] || { echo >&2 "Cluster variables file doesn't exist. Aborting."; exit 1; }
if ! yq validate "${CLUSTER_VARS}" > /dev/null 2>&1; then
  echo "Cluster variables file is invalid YAML. Aborting"
  exit 1
fi

message "Generating sealed-secrets"

while IFS= read -r -d '' file
do
  # Get secret file metadata (path, filename, etc...)
  secret_path="$(dirname "$file")"
  secret_relative_path=${secret_path#"${SECRETS_ROOT}"}
  secret_filename="$(basename "$file")"
  secret_name=$(basename -s .yaml "$file")
  secret_namespace=$(echo "$secret_relative_path" | awk -F/ '{print $2}')

  # Don't create a secret for the cluster-vars YAML
  if [[ "$file" == "$CLUSTER_VARS" ]]; then
    continue
  fi

  # Don't create any actual secrets for any sample YAMLs
  if [[ "$file" == *sample.yaml ]]; then
    continue
  fi

  echo "- Processing ${secret_relative_path}/${secret_filename}"

  # Make sure the file is valid YAML before we try to read it
  if ! yq validate "${file}" > /dev/null 2>&1; then
    echo "${secret_relative_path}/${secret_filename} is invalid YAML. Aborting"
    exit 1
  fi

  # Get the secret type
  secret_type=$(yq r --defaultValue "Opaque" "$file" 'type')

  # Process the secret yaml to replace any variables
  rendered_file=$(renderizer --settings="${CLUSTER_VARS}" "${file}")

  # Create a named pipe so that we can append the base64 values later
  pipe="rendered_secret"
  trap 'rm -f $pipe' ERR
  trap 'rm -f $pipe' EXIT
  if [[ ! -p "$pipe" ]]; then
    mkfifo "$pipe"
  fi

  # Initialize the rendered secret from the template and add
  # the secret name and namespace
  yq w - "type" "${secret_type}" < "${TEMPLATES_ROOT}/secret.yaml" \
    | \
  yq w - "metadata.name" "${secret_name}" \
    | \
  yq w - "metadata.namespace" "${secret_namespace}" > $pipe &

  # Loop over the data yaml keys, base64 them and append them
  # to the generated secret
  for secretkey in $(yq r --printMode p "$file" 'data.*'); do
    secretvalue=$(echo -n "$rendered_file" | yq r - "$secretkey")
    secret_lines=$(echo "$secretvalue" | wc -l)

    # If it's a multi-line string, add a newline at the end (mostly for keyfiles etc)
    if [[ $secret_lines -gt 1 ]]; then
      secretvalue="$secretvalue\n"
    fi

    secretvalue_encoded=$(echo -en "${secretvalue}" | base64)
    output=$(yq w - "$secretkey" "$secretvalue_encoded" < $pipe)
    echo -n "$output" > $pipe &
  done

  generated_secret=$(cat $pipe)

  # Make sure the generated secret is a valid Kubernetes Secret before proceeding
  if ! echo "$generated_secret" | kubeval --strict > /dev/null 2>&1; then
    echo "Invalid secret generated for ${secret_relative_path}/${secret_filename}. Aborting"
    exit 1
  fi

  # Write out the actual sealed-secret and remove useless creationTimestamp
  echo "$generated_secret" | kubeseal --format=yaml --cert="${PUB_CERT}" \
    | \
  yq d - "metadata.creationTimestamp" \
    | \
  yq d - "spec.template.metadata.creationTimestamp" > "${CLUSTER_ROOT}""${secret_relative_path}"/sealedsecret-"${secret_name}".yaml

done <   <(find "${SECRETS_ROOT}" -name '*.yaml' -print0)

message "all done!"
