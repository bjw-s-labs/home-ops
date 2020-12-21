#!/usr/bin/env bash
set -e

REPO_ROOT=$(git rev-parse --show-toplevel)
CLUSTER_ROOT="${REPO_ROOT}/cluster"
REPOSITORY_FILES="${CLUSTER_ROOT}/system-flux/helm-chart-repositories"

need() {
    command -v "$1" &>/dev/null || (echo "Binary '$1' is missing but required" && exit 1)
}

need "yq"

while IFS= read -r -d '' helm_release
do
    # ignore flux-system namespace
    # ignore wrong apiVersion
    # ignore non HelmReleases
    if [[ "${helm_release}" =~ "system-flux"
        || $(yq eval '.apiVersion' "${helm_release}") != "helm.toolkit.fluxcd.io/v2beta1"
        || $(yq eval '.kind' "${helm_release}") != "HelmRelease" ]]; then
        continue
    fi

    for file in "${REPOSITORY_FILES}"/*.yaml; do
        chart_name=$(yq eval '.metadata.name' "$file")
        chart_url=$(yq eval '.spec.url' "$file")

        # ignore if the chart name does not match
        if [[ $(yq eval '.spec.chart.spec.sourceRef.name' "${helm_release}") == "${chart_name}" ]]; then
            # delete "renovate: registryUrl=" line
            sed -i "/renovate: registryUrl=/d" "${helm_release}"
            # insert "renovate: registryUrl=" line
            sed -i "/.*chart: .*/i \ \ \ \ \ \ # renovate: registryUrl=${chart_url}" "${helm_release}"
            echo "Annotated $(basename "${helm_release%.*}") with ${chart_name} for renovatebot..."
            break
        fi
    done
done <   <(find ${CLUSTER_ROOT} -type f -name "*.yaml" -print0)
