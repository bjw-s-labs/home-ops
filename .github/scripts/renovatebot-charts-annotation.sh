#!/usr/bin/env bash
set -e

REPO_ROOT=$(git rev-parse --show-toplevel)
CLUSTER_ROOT="${REPO_ROOT}/cluster"
REPOSITORY_FILES="${CLUSTER_ROOT}/system-flux/helm-chart-repositories"

need() {
    command -v "$1" &>/dev/null || (echo "Binary '$1' is missing but required" && exit 1)
}

need "yq"

for helm_release in $(find ${CLUSTER_ROOT} -type f -name "*.yaml" ); do
    # ignore flux-system namespace
    # ignore wrong apiVersion
    # ignore non HelmReleases
    if [[ "${helm_release}" =~ "system-flux"
        || $(yq r "${helm_release}" apiVersion) != "helm.toolkit.fluxcd.io/v2beta1"
        || $(yq r "${helm_release}" kind) != "HelmRelease" ]]; then
        continue
    fi

    for file in "${REPOSITORY_FILES}"/*.yaml; do
        chart_name=$(yq r "$file" metadata.name)
        chart_url=$(yq r "$file" spec.url)

        # ignore if the chart name does not match
        if [[ $(yq r "${helm_release}" spec.chart.spec.sourceRef.name) == "${chart_name}" ]]; then
            gsed -i "/.*chart: .*/i \ \ \ \ \ \ # renovate: registryUrl=${chart_url}" "${helm_release}"
            echo "Annotated $(basename "${helm_release%.*}") with ${chart_name} for renovatebot..."
            break
        fi
    done
done
