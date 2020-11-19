#!/bin/bash
set -e

REPO_ROOT=$(git rev-parse --show-toplevel)
DEPLOYMENTS_ROOT="${REPO_ROOT}/cluster"
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
  FILES_TO_PROCESS=$(find "${DEPLOYMENTS_ROOT}" -type f -name "*.tmpl")
fi

# Validate cluster vars file
[ -f "${CLUSTER_VARS}" ] || { echo >&2 "Cluster variables file doesn't exist. Aborting."; exit 1; }
if ! yq validate "${CLUSTER_VARS}" > /dev/null 2>&1; then
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
  if [[ $file != ${DEPLOYMENTS_ROOT}* ]]; then
    continue
  fi

  # Only process .tmpl files
  if [[ $file != ${DEPLOYMENTS_ROOT}*.tmpl ]]; then
    continue
  fi

  # Get secret file metadata (path, filename, etc...)
  template_filename="${file##*/}"
  template_path="${file%/$template_filename}"
  template_relative_path=${template_path#"${DEPLOYMENTS_ROOT}"}

  template_target_name=${template_filename%.*}
  template_namespace=$(echo "$template_relative_path" | awk -F/ '{print $2}')
  template_deployment=$(echo "$template_relative_path" | awk -F/ '{print $3}')
  template_vars_path="${SECRETS_ROOT}${template_relative_path}"
  template_vars_filename="${template_vars_path}/vars.yaml"

  if [ "${template_deployment}" == "" ]; then
    template_deployment="${template_namespace}"
  fi

  echo "- Processing $file"

  # Double check to see if the file exists
  if [[ ! -f "$file" ]]; then
    echo "  ${file} does not exist. Aborting"
    exit 1
  fi

  VARS_FOUND=0
  if [[ -f "$template_vars_filename" ]]; then
    VARS_FOUND=1
  fi

  # Make sure the vars file is valid YAML before we try to read it
  if [ "$VARS_FOUND" -eq 1 ] && ! yq validate "${template_vars_filename}" > /dev/null 2>&1; then
    echo "  ${template_vars_filename} is invalid YAML. Aborting"
    exit 1
  fi

  # Process the template to replace any variables
  if [ "$VARS_FOUND" -eq 1 ]; then
    rendered_file=$(gomplate -c "cluster-vars=${CLUSTER_VARS}" -c "${template_deployment}=${template_vars_filename}" -f "${file}")
  else
    rendered_file=$(gomplate -c "cluster-vars=${CLUSTER_VARS}" -f "${file}")
  fi

  if [[ "$DEBUG" == "true" ]]; then
    echo "** DEBUG ** Rendered file"
    echo "${rendered_file}"
    echo ""
  fi

  # Make sure the rendered template is valid YAML before proceeding
  if ! echo "$rendered_file" | yq validate - > /dev/null 2>&1; then
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
    template_target_name="${template_deployment}-helm-values.yaml"
    echo -n "${rendered_file}" |
    kubectl -n "${template_namespace}" create secret generic "${template_deployment}-helm-values" \
        --from-file=/dev/stdin --dry-run=client -o yaml |
    # Remove null keys
    yq d - "metadata.creationTimestamp" |
    yq d - "spec.template.metadata.creationTimestamp" |
    yq w - "metadata.namespace" "${template_namespace}" |
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
  if ! echo "$rendered_template" | kubeval --strict > /dev/null 2>&1; then
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
    yq d - "metadata.creationTimestamp" |
    yq d - "spec.template.metadata.creationTimestamp" >> "${template_path}/$template_target_name"
  else
    # Output the file to the desired path
    echo "$rendered_template" > "${template_path}/$template_target_name"
  fi

done <<< "$FILES_TO_PROCESS"

message "all done!"
