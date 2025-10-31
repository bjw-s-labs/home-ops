set quiet := true
set shell := ['bash', '-euo', 'pipefail', '-c']

kubernetes_dir := justfile_dir() + '/kubernetes'
bootstrap_dir := kubernetes_dir + '/bootstrap'
controller := `talosctl config info --output json | jq --raw-output '.endpoints[]' | shuf -n 1`
nodes := `talosctl config info -o yaml | yq -e '.nodes | join (" ")'`

[private]
default: talos kubernetes (kubeconfig "node") wait namespaces resources crds apps kubeconfig

[doc('Install Talos')]
talos stage="apply_machineconfig":
  just log info "Running stage..." "stage" "{{stage}}"
  for n in {{ nodes }}; do \
    if ! op=$(just talos::apply-node "$n" --insecure 2>&1); then \
      if [[ "$op" == *"certificate required"* ]]; then \
        just log info "Talos already configured, skipping apply of config" "stage" "{{stage}}" "node" "$n"; \
        continue; \
      fi; \
      just log fatal "Failed to apply Talos configuration" "stage" "{{stage}}" "node" "$n" "output" "$op"; \
    fi; \
  done

[doc('Install Kubernetes')]
kubernetes stage="bootstrap_kubernetes":
  just log info "Running stage..." "stage" "{{stage}}"
  until op=$(talosctl -n "{{ controller }}" bootstrap 2>&1 || true) && [[ "$op" == *"AlreadyExists"* ]]; do \
    just log info "Kubernetes bootstrap in progress. Retrying in 5 seconds..." "stage" "{{stage}}"; \
    sleep 5; \
  done

[doc('Fetch kubeconfig')]
kubeconfig lb="cilium" stage="fetch_kubeconfig":
  just log info "Running stage..." "stage" "{{stage}}"
  if ! talosctl kubeconfig -n "{{ controller }}" -f --force-context-name home-ops {{ justfile_dir() }}; then \
    just log fatal "Failed to fetch kubeconfig" "stage" "{{stage}}"; \
  fi
  if [[ "{{ lb }}" != "cilium" ]]; then \
    if ! kubectl config set-cluster home-ops --server "https://{{ controller }}:6443"; then \
      just log fatal "Failed to set kubectl cluster server address" "stage" "{{stage}}"; \
    fi; \
  fi

[doc('Wait for nodes to be not-ready')]
wait stage="wait_for_nodes":
  just log info "Running stage..." "stage" "{{stage}}"
  if ! kubectl wait nodes --for=condition=Ready=True --all --timeout=10s &>/dev/null; then \
    until kubectl wait nodes --for=condition=Ready=False --all --timeout=10s &>/dev/null; do \
      just log info "Nodes not available, waiting for nodes to be available. Retrying in 5 seconds..." "stage" "{{stage}}"; \
      sleep 5; \
    done \
  fi

[doc('Apply Kubernetes namespaces')]
namespaces stage="create_namespaces":
  just log info "Running stage..." "stage" "{{stage}}"
  find "{{ kubernetes_dir }}/apps" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | while IFS= read -r ns; do \
    if ! kubectl create namespace "$ns" --dry-run=client -o yaml | kubectl apply --server-side -f -; then \
      just log fatal "Failed to apply namespace" "stage" "create_namespaces" "namespace" "$ns"; \
    fi; \
  done

[doc('Apply Kubernetes resources')]
resources stage="apply_resources":
  just log info "Running stage..." "stage" "{{stage}}"
  if ! just template "{{ bootstrap_dir }}/resources.yaml.j2" | kubectl apply --server-side -f -; then \
    just log fatal "Failed to apply resources" "stage" "{{stage}}"; \
  fi;

[doc('Apply Helmfile CRDs')]
crds stage="apply_crds":
  just log info "Running stage..." "stage" "{{stage}}"
  if ! helmfile -f "{{ bootstrap_dir }}/helmfile.d/00-crds.yaml" template -q | kubectl apply --server-side -f -; then \
    just log fatal "Failed to apply crds" "stage" "{{stage}}"; \
  fi;

[doc('Apply Helmfile Apps')]
apps stage="apply_apps":
  just log info "Running stage..." "stage" "{{stage}}"
  if ! helmfile -f "{{ bootstrap_dir }}/helmfile.d/01-apps.yaml" sync --hide-notes; then \
    just log fatal "Failed to sync helmfile" "stage" "{{stage}}"; \
  fi
