#!/bin/bash
REPO_ROOT=$(git rev-parse --show-toplevel)
CLUSTER_ROOT="${REPO_ROOT}/deployments"
SECRETS_ROOT="${REPO_ROOT}/.secrets"
PUB_CERT="${REPO_ROOT}/_setup/sealedsecret-cert.pem"

need() {
    which "$1" &>/dev/null || die "Binary '$1' is missing but required"
}

need "kubectl"
need "envsubst"
need "yq"

# Load cluster-vars.env file
set -a
. "${SECRETS_ROOT}/cluster-vars.env"
set +a

message() {
  echo -e "\n######################################################################"
  echo "# $1"
  echo "######################################################################"
}

message "Generating sealed-secrets"

while IFS= read -r -d '' file
do
  # Get the path and basename of the txt file
  # e.g. "deployments/default/pihole/pihole"
  secret_path="$(dirname "$file")"

  # Get the secret name
  secret_name=$(basename -s .yaml "$file")

  # Get the relative path of deployment
  deployment=${secret_path#"${SECRETS_ROOT}"}

  # Get the namespace (based on folder path of manifest)
  namespace=$(echo $deployment | awk -F/ '{print $2}')

  echo "- Processing $deployment/$secret_name.yaml"

  envsubst < "${file}" \
    | \
  yq w "${file}" "metadata.name" "${secret_name}" \
    | \
  yq w "${file}" "metadata.namespace" "${namespace}" \
    | \
  kubeseal --format=yaml --cert="${PUB_CERT}" \
    | \
  yq d - "metadata.creationTimestamp" \
    | \
  yq d - "spec.template.metadata.creationTimestamp" > "${CLUSTER_ROOT}""${deployment}"/sealedsecret-"${secret_name}".yaml
done <   <(find "${SECRETS_ROOT}" -name '*.yaml' -print0)

message "all done!"
