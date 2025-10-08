set quiet := true
set shell := ['bash', '-euo', 'pipefail', '-c']

kubernetes_dir := justfile_dir() + '/kubernetes'
talos_dir := kubernetes_dir + '/talos'
controller := `talosctl config info --output json | jq --raw-output '.endpoints[]' | shuf -n 1`

[private]
default:
  just -l talos

[doc('Apply Talos config to a node')]
apply-node node *args:
  just talos render-config "{{ node }}" | talosctl -n "{{ node }}" apply-config -f /dev/stdin {{ args }}

[doc('Apply Talos config to all nodes in the cluster')]
apply-cluster *args:
  kubectl get nodes --no-headers | while read -r node _; do \
    just log info "Applying Talos config to node ${node}"; \
    just talos apply-node ${node} {{ args }}; \
  done

[doc('Generate schematic ID from Talos schematic')]
gen-schematic-id:
  curl -sX POST --data-binary "@{{ talos_dir }}/schematic.yaml" "https://factory.talos.dev/schematics" | jq -r '.id'

[doc('Render Talos config for a node')]
render-config node:
  export IS_CONTROLPLANE="$(just talos machine-controller {{ node }})"; \
  talosctl machineconfig patch <(just template "{{ talos_dir }}/machineconfig.yaml.j2") \
    -p @<(just template "{{ talos_dir }}/nodes/{{ node }}.yaml.j2")

[doc('Reboot a node')]
reboot-node node:
  gum confirm "Reboot node {{ node }}?" && \
    talosctl -n {{ node }} reboot -m powercycle || exit 0

[doc('Reset a node')]
reset-node node mode="reboot":
  gum confirm "Reset node {{ node }}?" && \
    talosctl -n "{{ node }}" reset --graceful=false {{ if mode == "reboot" { "--reboot" } else { "" } }} || exit 0

[doc('Reset all nodes in the cluster')]
reset-cluster mode="reboot":
  kubectl get nodes --no-headers | while read -r node _; do \
    just log info "Resetting Talos node ${node}";\
    just talos reset-node ${node} {{ mode }};\
  done

[doc('Upgrade Kubernetes version on the cluster')]
upgrade-k8s version:
  talosctl -n "{{ controller }}" upgrade-k8s --to {{ version }}

[doc('Upgrade Talos version on a node')]
upgrade-node node:
  talosctl -n "{{ node }}" upgrade -i "$(just talos machine-image {{ node }})" -m powercycle --timeout=10m

[doc('Download Talos machine image')]
download-image version schematic:
  gum spin --title "Downloading Talos {{ version }} ..." -- \
  curl -sfL --remove-on-error --retry 5 --retry-delay 5 --retry-all-errors \
      -o "{{ talos_dir }}/talos-{{ version }}-{{ replace_regex(schematic, '^(.{8}).*', '$1') }}.iso" \
      "https://factory.talos.dev/image/{{ schematic }}/{{ version }}/metal-amd64.iso"
  just log info "Downloaded Talos" version "{{ version }}" schematic "{{ schematic }}"

[private]
machine-controller node:
  just template "{{ talos_dir }}/nodes/{{ node }}.yaml.j2" | yq -e 'select(.machine) | (.machine.type == "controlplane") // ""'

[doc('Get the machine image for a given node')]
[private]
machine-image node:
  talosctl --nodes {{ node }} get machineconfig --output=jsonpath='{.spec}' | yq -e 'select(.machine) | .machine.install.image'
