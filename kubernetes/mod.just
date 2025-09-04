set quiet := true
set shell := ['bash', '-euo', 'pipefail', '-c']

kubernetes_dir := justfile_dir() + '/kubernetes'

[private]
default:
  just -l talos

[doc('Browse a PVC')]
browse-pvc namespace claim:
  kubectl browse-pvc -n {{ namespace }} -i mirror.gcr.io/alpine:latest {{ claim }}

[doc('Open a shell on a node')]
node-shell node:
  kubectl debug node/{{ node }} -n default -it --image='mirror.gcr.io/alpine:latest' --profile sysadmin
  kubectl delete pod -n default -l app.kubernetes.io/managed-by=kubectl-debug

[doc('Prune pods in Failed, Pending, or Succeeded state')]
prune-pods:
  for phase in Failed Pending Succeeded; do \
    kubectl delete pods -A --field-selector status.phase="$phase" --ignore-not-found=true; \
  done

[doc('Sync single Flux HelmRelease')]
sync-hr ns name:
  kubectl -n "{{ ns }}" annotate --field-manager flux-client-side-apply --overwrite hr "{{ name }}" reconcile.fluxcd.io/requestedAt="$(date +%s)" reconcile.fluxcd.io/forceAt="$(date +%s)"; \

[doc('Sync single Flux Kustomizations')]
sync-ks ns name:
  kubectl -n "{{ ns }}" annotate --field-manager flux-client-side-apply --overwrite ks "{{ name }}" reconcile.fluxcd.io/requestedAt="$(date +%s)"; \

[doc('Sync single ExternalSecret')]
sync-es ns name:
  kubectl -n "{{ ns }}" annotate --field-manager flux-client-side-apply --overwrite es "{{ name }}" force-sync="$(date +%s)"; \

[doc('Sync all Flux HelmReleases')]
sync-all-hr:
  kubectl get hr --no-headers -A | while read -r ns name _; do \
    just k8s sync-hr "$ns" "$name"; \
  done

[doc('Sync all Flux Kustomizations')]
sync-all-ks:
  kubectl get ks --no-headers -A | while read -r ns name _; do \
    just k8s sync-ks "$ns" "$name"; \
  done

[doc('Sync all ExternalSecrets')]
sync-all-es:
  kubectl get es --no-headers -A | while read -r ns name _; do \
    just k8s sync-es "$ns" "$name"; \
  done
