set default-list
set default-script
set quiet
set script-interpreter := ['bash', '-euo', 'pipefail']
set shell := ['bash', '-euo', 'pipefail', '-c']

# ------
# Kubernetes
# ------
[doc('Browse a PVC')]
browse-pvc namespace claim:
    kubectl run -n {{ namespace }} browse-pvc-{{ claim }} -it --rm --restart=Never \
        --image=mirror.gcr.io/alpine:latest \
        --overrides='{"spec":{"containers":[{"name":"browse-pvc-{{ claim }}","image":"mirror.gcr.io/alpine:latest","stdin":true,"tty":true,"command":["/bin/sh"],"workingDir":"/mnt","volumeMounts":[{"mountPath":"/mnt","name":"data"}]}],"volumes":[{"name":"data","persistentVolumeClaim":{"claimName":"{{ claim }}"}}]}}'

[doc('Debug a node')]
debug-node node:
    trap 'kubectl delete pod -n default -l app.kubernetes.io/managed-by=kubectl-debug --field-selector spec.nodeName={{ node }} --ignore-not-found --wait=false' EXIT
    kubectl debug node/{{ node }} -n default -it --image=mirror.gcr.io/alpine:latest --profile=sysadmin

[doc('Prune pods in Failed, Pending, or Succeeded state')]
prune-pods:
    for phase in Failed Pending Succeeded; do
      kubectl delete pods -A --field-selector status.phase="$phase" --ignore-not-found=true
    done

# ------
# Flux
# ------
[doc('Apply local Flux Kustomization')]
apply-ks ns ks:
    just k8s render-local-ks "{{ ns }}" "{{ ks }}" | kubectl apply --server-side --force-conflicts --field-manager=kustomize-controller -f -

[doc('Delete local Flux Kustomization')]
delete-ks ns ks:
    just k8s render-local-ks "{{ ns }}" "{{ ks }}" | kubectl delete -f -

[doc('Sync single Flux HelmRelease')]
sync-hr ns name:
    kubectl -n "{{ ns }}" annotate --field-manager flux-client-side-apply --overwrite hr "{{ name }}" reconcile.fluxcd.io/requestedAt="$(date +%s)" reconcile.fluxcd.io/forceAt="$(date +%s)"

[doc('Sync single Flux Kustomizations')]
sync-ks ns name:
    kubectl -n "{{ ns }}" annotate --field-manager flux-client-side-apply --overwrite ks "{{ name }}" reconcile.fluxcd.io/requestedAt="$(date +%s)"

[doc('Sync all Flux HelmReleases')]
sync-all-hr:
    kubectl get hr --no-headers -A | while read -r ns name _; do
      just k8s sync-hr "${ns}" "${name}"
    done

[doc('Sync all Flux Kustomizations')]
sync-all-ks:
    kubectl get ks --no-headers -A | while read -r ns name _; do
      just k8s sync-ks "${ns}" "${name}"
    done

[private]
render-local-ks ns ks:
    flate build ks --namespace "{{ ns }}" --output yaml "{{ ks }}"

# ------
# ESO
# ------
[doc('Sync single ExternalSecret')]
sync-es ns name:
    kubectl -n "{{ ns }}" annotate --field-manager flux-client-side-apply --overwrite es "{{ name }}" force-sync="$(date +%s)"

[doc('Sync all ExternalSecrets')]
sync-all-es:
    kubectl get es --no-headers -A | while read -r ns name _; do
      just k8s sync-es "$ns" "$name"
    done

# ------
# Kopiur
# ------
[doc('Trigger Kopiur Snapshotpolicy')]
snapshot-kopiur ns name:
    kubectl kopiur -n "{{ ns }}" snapshot now --policy "{{ name }}"

[doc('Trigger all Kopiur Snapshotpolicies')]
snapshot-kopiur-all:
    kubectl get snapshotpolicies.kopiur.home-operations.com --no-headers -A | while read -r ns name _; do
      just k8s snapshot-kopiur "$ns" "$name"
    done
