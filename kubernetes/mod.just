set lazy
set positional-arguments
set quiet
set script-interpreter := ['bash', '-euo', 'pipefail']
set shell := ['bash', '-euo', 'pipefail', '-c']

[private]
[script]
default:
    just -l talos

[doc('Browse a PVC')]
[script]
browse-pvc namespace claim:
    kubectl browse-pvc -n {{ namespace }} -i mirror.gcr.io/alpine:latest {{ claim }}

[doc('Open a shell on a node')]
[script]
node-shell node:
    kubectl debug node/{{ node }} -n default -it --image='mirror.gcr.io/alpine:latest' --profile sysadmin
    kubectl delete pod -n default -l app.kubernetes.io/managed-by=kubectl-debug

[doc('Prune pods in Failed, Pending, or Succeeded state')]
[script]
prune-pods:
    for phase in Failed Pending Succeeded; do
      kubectl delete pods -A --field-selector status.phase="$phase" --ignore-not-found=true
    done

[doc('Apply local Flux Kustomization')]
[script]
apply-ks ns ks:
    just k8s render-local-ks "{{ ns }}" "{{ ks }}" | kubectl apply --server-side --force-conflicts --field-manager=kustomize-controller -f -

[doc('Delete local Flux Kustomization')]
[script]
delete-ks ns ks:
    just k8s render-local-ks "{{ ns }}" "{{ ks }}" | kubectl delete -f -

[doc('Sync single Flux HelmRelease')]
[script]
sync-hr ns name:
    kubectl -n "{{ ns }}" annotate --field-manager flux-client-side-apply --overwrite hr "{{ name }}" reconcile.fluxcd.io/requestedAt="$(date +%s)" reconcile.fluxcd.io/forceAt="$(date +%s)"

[doc('Sync single Flux Kustomizations')]
[script]
sync-ks ns name:
    kubectl -n "{{ ns }}" annotate --field-manager flux-client-side-apply --overwrite ks "{{ name }}" reconcile.fluxcd.io/requestedAt="$(date +%s)"

[doc('Sync single ExternalSecret')]
[script]
sync-es ns name:
    kubectl -n "{{ ns }}" annotate --field-manager flux-client-side-apply --overwrite es "{{ name }}" force-sync="$(date +%s)"

[doc('Sync all Flux HelmReleases')]
[script]
sync-all-hr:
    kubectl get hr --no-headers -A | while read -r ns name _; do
      just k8s sync-hr "$ns" "$name"
    done

[doc('Sync all Flux Kustomizations')]
[script]
sync-all-ks:
    kubectl get ks --no-headers -A | while read -r ns name _; do
      just k8s sync-ks "$ns" "$name"
    done

[doc('Sync all ExternalSecrets')]
[script]
sync-all-es:
    kubectl get es --no-headers -A | while read -r ns name _; do
      just k8s sync-es "$ns" "$name"
    done

[doc('Trigger Kopiur Snapshotpolicy')]
[script]
snapshot-kopiur ns name:
    kubectl kopiur -n "{{ ns }}" snapshot now --policy "{{ name }}"

[doc('Trigger all Kopiur Snapshotpolicies')]
[script]
snapshot-kopiur-all:
    kubectl get snapshotpolicies.kopiur.home-operations.com --no-headers -A | while read -r ns name _; do
      just k8s snapshot-kopiur "$ns" "$name"
    done

[private]
[script]
render-local-ks ns ks:
    flate build ks --namespace "{{ ns }}" --output yaml "{{ ks }}"
