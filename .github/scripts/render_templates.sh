#!/bin/bash
set -e

REPO_ROOT=$(git rev-parse --show-toplevel)
CLUSTER_ROOT="${REPO_ROOT}/cluster"
SECRETS_ROOT="${REPO_ROOT}/.secrets"
CLUSTER_VARS="${SECRETS_ROOT}/cluster-vars.yaml"
PUB_CERT="${SECRETS_ROOT}/sealedsecret-cert.pem"

while getopts i:r option
do
  case "${option}" in
  i) INPUT_FILE=${OPTARG};;
  *) echo "usage: $0 [-m] [-r]" >&2 && exit 1
 esac
done

need() {
    command -v "$1" &>/dev/null || (echo "Binary '$1' is missing but required" && exit 1)
}

need "kubectl"
need "kubeval"
need "gomplate"
need "yq"

message() {
  echo -e "\n######################################################################"
  echo "# $1"
  echo "######################################################################"
}

if [ -n "$INPUT_FILE" ]; then
  message "Processing files from $INPUT_FILE"
  if [ -f "$INPUT_FILE" ]; then
    FILES_TO_PROCESS=$(cat "$INPUT_FILE")
  else
    echo "File '$INPUT_FILE' does not exist. Aborting"
    exit 1
  fi
else
  FILES_TO_PROCESS=$(find "${CLUSTER_ROOT}" -type f -name "*.tmpl")
fi

# Validate cluster vars file
[ -f "${CLUSTER_VARS}" ] || { echo >&2 "Cluster variables file doesn't exist. Aborting."; exit 1; }
if ! yq eval "${CLUSTER_VARS}" > /dev/null; then
  echo "Cluster variables file is invalid YAML. Aborting"
  exit 1
fi

message "Processing templates"

# Loop over the files that should be processed
while IFS= read -r file; do
  # Convert relative paths to absolute paths
  if [[ "$file" != /* ]]; then
    file="$REPO_ROOT/$file"
  fi

  # Only process files in the deployments folder
  if [[ $file != ${CLUSTER_ROOT}* ]]; then
    continue
  fi

  # Only process .tmpl files
  if [[ $file != ${CLUSTER_ROOT}*.tmpl ]]; then
    continue
  fi

  echo "- Processing $file"

  # Double check to see if the file exists
  if [[ ! -f "$file" ]]; then
    echo "  ${file} does not exist. Aborting"
    exit 1
  fi

  # Get secret file metadata (path, filename, etc...)
  template_filename="${file##*/}"
  template_path="${file%/$template_filename}"
  template_relative_path=${template_path#"${CLUSTER_ROOT}/"}
  template_target_name=${template_filename%.*}

  # Determine secret namespace / deployment
  IFS="/" read -ra template_relative_path_arr <<< "$template_relative_path"
  template_base=${template_relative_path_arr[0]}
  template_namespace=${template_relative_path_arr[1]}
  template_folder=${template_relative_path_arr[2]}
  template_vars_path="${SECRETS_ROOT}/${template_base}/${template_namespace}/${template_folder}"

  if [[ -d "${template_vars_path}" ]]; then
    template_var_files=$(find "${template_vars_path}" -type f -name "*.yaml")
  else
    template_var_files=""
  fi

  if [[ "$DEBUG" == "true" ]]; then
    echo "  template_vars_path: ${template_vars_path}"
    echo "  template_var_files: ${template_var_files}"
  fi

  VARS_CMD_LINE=()
  if [[ -n "$template_var_files" ]]; then
    while IFS= read -r template_var_file; do
      var_name=${template_var_file##*/}
      var_name=${var_name%.*}

      VARS_CMD_LINE+=("-c")
      VARS_CMD_LINE+=("${var_name}=${template_var_file}")
    done <<< "$template_var_files"
  fi

  if [[ "$DEBUG" == "true" ]]; then
    echo "  VARS_CMD_LINE=${VARS_CMD_LINE[*]}"
  fi

  # Process the template to replace any variables
  rendered_file=$(gomplate -c "cluster-vars=${CLUSTER_VARS}" "${VARS_CMD_LINE[@]}" -f "${file}")

  if [[ "$DEBUG" == "true" ]]; then
    echo "** DEBUG ** Rendered file"
    echo "${rendered_file}"
    echo ""
  fi

  # Make sure the rendered template is valid YAML before proceeding
  if ! echo "$rendered_file" | yq eval - > /dev/null; then
    echo "  Invalid YAML generated for ${file}. Aborting"
    exit 1
  fi

  # Create a named pipe so that we can append the base64 values later
  pipe="rendered_template"
  trap 'rm -f $pipe' ERR
  trap 'rm -f $pipe' EXIT
  if [[ ! -p "$pipe" ]]; then
    mkfifo "$pipe"
  fi

  # If it's a values.yaml file, process it and send it to kubeseal
  if [[ "$template_filename" == "values.yaml.tmpl" ]]; then
    template_target_name="${template_folder}-helm-values.yaml"
    echo -n "${rendered_file}" |
    kubectl -n "${template_namespace}" create secret generic "${template_folder}-helm-values" \
        --from-file=/dev/stdin --dry-run=client -o yaml |
    # Remove null keys
    yq eval 'del(.metadata.creationTimestamp)' - |
    yq eval 'del(.spec.template.metadata.creationTimestamp)' - |
    yq eval ".metadata.namespace = \"${template_namespace}\"" - |
    yq eval ".metadata.annotations.\"sealedsecrets.bitnami.com/managed\" = \"true\"" - |
    sed -e 's/stdin\:/values.yaml\:/g' > $pipe &
  else
    echo -n "${rendered_file}" > $pipe &
  fi

  rendered_template=$(cat $pipe)

  if [[ "$DEBUG" == "true" ]]; then
    echo "** DEBUG ** Rendered template"
    echo "${rendered_template}"
  fi

  # Make sure the rendered_template file is a valid Kubernetes YAML before proceeding
  if ! echo "$rendered_template" | kubeval --ignore-missing-schemas > /dev/null 2>&1; then
    echo "  Invalid YAML generated for ${file}. Aborting"
    exit 1
  fi

  SECRET_REGEX="^(secret-.*|values)\.yaml\.tmpl$"
  if [[ $template_filename =~ $SECRET_REGEX ]]; then
    # Render file to a sealedsecret
    template_target_name=${template_target_name#"secret-"}
    template_target_name="sealedsecret-${template_target_name}"
    mkdir -p "${template_path}"
    echo "---" > "${template_path}/$template_target_name"
    echo "$rendered_template" | kubeseal --format=yaml --cert="${PUB_CERT}" |
    yq eval 'del(.metadata.creationTimestamp)' - |
    yq eval 'del(.spec.template.metadata.creationTimestamp)' - >> "${template_path}/$template_target_name"
  else
    # Output the file to the desired path
    echo "$rendered_template" > "${template_path}/$template_target_name"
  fi

done <<< "$FILES_TO_PROCESS"

message "all done!"
