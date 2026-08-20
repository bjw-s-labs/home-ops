set default-list
set default-script
set quiet
set script-interpreter := ['bash', '-euo', 'pipefail']
set shell := ['bash', '-euo', 'pipefail', '-c']

[confirm('Apply Talos config to ' + node + ' [y|N] ?')]
[doc('Apply Talos config to a node')]
apply-node node *args:
    just log info "Applying Talos machineconfig" "node" "{{ node }}";
    just talos render-config "{{ node }}" | talosctl -n "{{ node }}" apply-config -f /dev/stdin {{ args }}

[confirm('Apply Talos config to all nodes in cluster [y|N] ?')]
[doc('Apply Talos config to all nodes in the cluster')]
apply-cluster *args:
    kubectl get nodes --no-headers | while read -r node _; do
      just --yes talos apply-node ${node} {{ args }}
    done

[doc('Render Talos config for a node')]
render-config node:
    export SCHEMATIC="$(just talos schematic-id "{{ node }}")"
    export TALOS_VERSION="$(just talos talos-version)"
    export K8S_VERSION="$(just talos k8s-version)"
    role="controlplane"
    if [[ -f "{{ source_directory() }}/nodes/workers/{{ node }}.yaml.j2" ]]; then
        role="workers"
    fi
    talosctl machineconfig patch <(just template "{{ source_directory() }}/cluster.yaml.j2" -D "schematic=${SCHEMATIC}" -D "talos_version=${TALOS_VERSION}" -D "k8s_version=${K8S_VERSION}") \
        -p @<(just template "{{ source_directory() }}/${role}.yaml.j2") \
        -p @<(just template "{{ source_directory() }}/nodes/${role}/{{ node }}.yaml.j2")

[confirm('Reset node ' + node + ' [y|N] ?')]
[doc('Reset a node')]
reset-node node *args:
    talosctl -n "{{ node }}" reset --system-labels-to-wipe STATE --system-labels-to-wipe EPHEMERAL --system-labels-to-wipe u-local-hostpath --graceful=false {{ args }}

[confirm('Shutdown node ' + node + ' [y|N] ?')]
[doc('Shutdown a node')]
shutdown-node node *args:
    talosctl -n "{{ node }}" shutdown --force {{ args }}

[confirm('Upgrade Kubernetes to ' + version + ' [y|N] ?')]
[doc('Upgrade Kubernetes version on the cluster')]
upgrade-k8s version:
    talosctl -n "$(talosctl config info -o yaml | yq -r -e '.endpoints[0]')" upgrade-k8s --to {{ version }}

[confirm('Upgrade node ' + node + ' [y|N] ?')]
[doc('Upgrade Talos version on a node')]
upgrade-node node *args:
    talosctl -n "{{ node }}" upgrade -i "$(just talos machine-image "{{ node }}")" -m powercycle --timeout=10m {{ args }}

[doc('Download Talos machine image')]
download-image version node="":
    export SCHEMATIC="$(just talos schematic-id "{{ node }}")"
    curl -fL --remove-on-error --retry 5 --retry-delay 5 --retry-all-errors --progress-bar \
        -o "{{ source_directory() }}/talos-{{ version }}-${SCHEMATIC:0:8}.iso" \
        "https://factory.talos.dev/image/${SCHEMATIC}/{{ version }}/metal-amd64.iso"
    just log info "Downloaded Talos" version "{{ version }}" schematic "${SCHEMATIC}"

[doc('Fetch Talos version from configuration')]
[private]
talos-version:
    yq eval '.talos_version' "{{ source_directory() }}/version.yaml"

[doc('Fetch Kubernetes version from configuration')]
[private]
k8s-version:
    yq eval '.k8s_version' "{{ source_directory() }}/version.yaml"

[private]
schematic-file node="":
    file="{{ source_directory() }}/schematic.yaml"
    if [[ -n "{{ node }}" ]]; then
        for f in "{{ source_directory() }}"/nodes/*/"{{ node }}".schematic.yaml; do
            [[ -f "$f" ]] && file="$f"
        done
    fi
    echo "$file"

[private]
schematic-id node="":
    curl -sX POST --data-binary @<(just template "$(just talos schematic-file "{{ node }}")") "https://factory.talos.dev/schematics" | jq -r '.id'

[private]
machine-image node="":
    export NODE="{{ node }}"
    if [[ -z "${NODE}" ]]; then
        NODE="$(talosctl config info -o yaml | yq -r -e '.nodes[0]')"
    fi
    just talos render-config "${NODE}"  | yq -r -e 'select(.kind == "UnattendedInstallConfig") | .installer.image'
