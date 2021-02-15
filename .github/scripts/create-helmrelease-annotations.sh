#!/usr/bin/env bash
set -e

REPO_ROOT=$(git rev-parse --show-toplevel)
CLUSTER_ROOT="${REPO_ROOT}/cluster"
NAMESPACES_ROOT="${CLUSTER_ROOT}/namespaces"
REPOSITORY_FILES="${CLUSTER_ROOT}/base/system-flux/helm-chart-repositories"

# MacOS work-around for sed
 if [ "$(uname)" == "Darwin" ]; then
    # Check if gnu-sed exists
    command -v gsed >/dev/null 2>&1 || {
        echo >&2 "gsed is not installed. Aborting."
        exit 1
    }
    # Export path w/ gnu-sed
    export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
fi

while IFS= read -r -d '' helm_release
do
    if ! grep -q "apiVersion: helm.toolkit.fluxcd.io/v2beta1" "${helm_release}" || ! grep -q "kind: HelmRelease" "${helm_release}"; then
        continue
    fi

    helm_release_path=$(dirname "${helm_release}")

    for file in "${REPOSITORY_FILES}"/*.yaml; do
        registry_name=$(awk '/metadata/{flag=1} flag && /name:/{print $NF;flag=""}' "$file")
        registry_url=$(awk '/spec/{flag=1} flag && /url:/{print $NF;flag=""}' "$file")

        if grep -q "name: ${registry_name}" "${helm_release}"; then
            echo "Annotating HelmRelease ${helm_release_path#$NAMESPACES_ROOT/} with registry ${registry_name} for renovatebot..."
            # delete "renovate: registryUrl=" line
            sed -i "/renovate: registryUrl=/d" "${helm_release}"
            # insert "renovate: registryUrl=" line
            sed -i "/.*chart: .*/i \ \ \ \ \ \ # renovate: registryUrl=${registry_url}" "${helm_release}"
            break
        fi
    done
done <   <(find "${NAMESPACES_ROOT}" -type f -name "*.yaml" -print0)
