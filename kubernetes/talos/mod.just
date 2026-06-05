set lazy
set positional-arguments
set quiet
set script-interpreter := ['bash', '-euo', 'pipefail']
set shell := ['bash', '-euo', 'pipefail', '-c']

kubernetes_dir := justfile_dir() + '/kubernetes'
talos_dir := kubernetes_dir + '/talos'
controller := `talosctl config info --output json | jq --raw-output '.endpoints[]' | shuf -n 1`
nodes := `talosctl config info -o yaml | yq -e '.nodes | join (",")'`

[private]
[script]
default:
    just -l talos

[doc('Apply Talos config to a node')]
[script]
apply-node node *args:
    just log info "Applying Talos machineconfig" "node" "{{ node }}";
    just talos render-config "{{ node }}" | talosctl -n "{{ node }}" apply-config -f /dev/stdin {{ args }}

[doc('Apply Talos config to all nodes in the cluster')]
[script]
apply-cluster *args:
    kubectl get nodes --no-headers | while read -r node _; do
      just talos apply-node ${node} {{ args }}
    done

[doc('Generate schematic ID from Talos schematic')]
[script]
schematic-id:
    curl -sX POST --data-binary "@{{ talos_dir }}/schematic.yaml" "https://factory.talos.dev/schematics" | jq -r '.id'

[doc('Render Talos config for a node')]
[script]
render-config node:
    export IS_CONTROLPLANE="$(just talos machine-controller {{ node }})"
    export SCHEMATIC="$(just talos schematic-id)"
    export TALOS_VERSION="$(just talos version)"
    talosctl machineconfig patch <(just template "{{ talos_dir }}/machineconfig.yaml.j2") -p @<(just template "{{ talos_dir }}/nodes/{{ node }}.yaml.j2")

[doc('Reboot a node')]
[script]
reboot-node node:
    gum confirm "Reboot node {{ node }}?" &&
      talosctl -n {{ node }} reboot -m powercycle || exit 0

[doc('Reset a node')]
[script]
reset-node node mode="reboot":
    gum confirm "Reset node {{ node }}?" &&
      talosctl -n "{{ node }}" reset --system-labels-to-wipe STATE --system-labels-to-wipe EPHEMERAL --system-labels-to-wipe u-local-hostpath --graceful=false {{ if mode == "reboot" { "--reboot" } else { "" } }} || exit 0

[doc('Reset all nodes in the cluster')]
[script]
reset-cluster mode="reboot":
    just talos reset-node {{ nodes }} {{ mode }};\

[doc('Upgrade Kubernetes version on the cluster')]
[script]
upgrade-k8s version:
    talosctl -n "{{ controller }}" upgrade-k8s --to {{ version }}

[doc('Upgrade Talos version on a node')]
[script]
upgrade-node node:
    talosctl -n "{{ node }}" upgrade -i "$(just talos machine-image {{ node }})" -m powercycle --timeout=10m

[doc('Download Talos machine image')]
[script]
download-image version schematic:
    gum spin --title "Downloading Talos {{ version }} ..." --
    curl -sfL --remove-on-error --retry 5 --retry-delay 5 --retry-all-errors
        -o "{{ talos_dir }}/talos-{{ version }}-{{ replace_regex(schematic, '^(.{8}).*', '$1') }}.iso"
        "https://factory.talos.dev/image/{{ schematic }}/{{ version }}/metal-amd64.iso"
    just log info "Downloaded Talos" version "{{ version }}" schematic "{{ schematic }}"

[private]
[script]
machine-controller node:
    just template "{{ talos_dir }}/nodes/{{ node }}.yaml.j2" | yq -e 'select(.machine) | (.machine.type == "controlplane") // ""'

[doc('Get the machine image for a given node')]
[private]
[script]
machine-image node:
    talosctl --nodes {{ node }} get machineconfig -o yaml | yq -e 'select(.metadata.id == "v1alpha1") | .spec' | yq -e 'select(.machine) | .machine.install.image'

[doc('Fetch Talos version from configuration')]
[private]
[script]
version:
    yq eval '.version' "{{ talos_dir }}/version.yaml"
