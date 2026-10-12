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

# ------
# CloudNativePG
# ------

# Seed a brand new object store prefix with an initial base backup, so that the
# permanent `bootstrap.recovery` stanza in components/cnpg has something to recover
# from. Run ONCE per new database, from a working tree that has the app committed
# locally but not yet pushed. Never needed for disaster recovery -- only when the
# database is created, or if the bucket itself is ever lost.
[confirm('Seed the CloudNativePG object store for Kustomization ' + ks + ' in ' + ns + ' [y|N] ?')]
[doc('Seed a new CloudNativePG object store prefix with an initial base backup')]
seed-cnpg ns ks:
    manifest="$(just k8s render-local-ks "{{ ns }}" "{{ ks }}")"

    cluster="$(yq -r 'select(.kind == "Cluster") | .metadata.name' <<<"${manifest}")"
    if [[ -z "${cluster}" ]]; then
      just log fatal "No CloudNativePG Cluster rendered" "namespace" "{{ ns }}" "kustomization" "{{ ks }}"
    fi
    if kubectl -n "{{ ns }}" get cluster "${cluster}" &>/dev/null; then
      just log fatal "Cluster already exists, refusing to seed" "namespace" "{{ ns }}" "cluster" "${cluster}"
    fi

    seed="${cluster}-seed"
    backup="${seed}-$(date +%s)"
    trap "kubectl -n '{{ ns }}' delete cluster \"${seed}\" --ignore-not-found --wait=true" EXIT

    just log info "Applying object store and credentials" "namespace" "{{ ns }}" "cluster" "${cluster}"
    ES="${cluster}-objectstore" yq -r '
        select(.kind == "ObjectStore"
               or (.kind == "ExternalSecret" and .metadata.name == strenv(ES)))
      ' <<<"${manifest}" \
      | kubectl -n "{{ ns }}" apply --server-side --force-conflicts --field-manager=kustomize-controller -f -
    kubectl -n "{{ ns }}" wait externalsecret "${cluster}-objectstore" --for=condition=Ready --timeout=2m

    # Same manifest Flux will apply, with bootstrap.recovery swapped for initdb. Only
    # the Cluster is renamed: serverName is left exactly as rendered, so the seed
    # writes its base backup into the prefix the real cluster will later recover from
    # and archive into. Do NOT re-derive serverName from the cluster name -- it
    # carries a -pgNN suffix and the two are deliberately different strings.
    just log info "Creating temporary seed cluster" "namespace" "{{ ns }}" "cluster" "${seed}"
    yq -r 'select(.kind == "Cluster")' <<<"${manifest}" \
      | SEED="${seed}" yq -r '
          . as $c
          | .metadata.name = strenv(SEED)
          | .spec.instances = 1
          | .spec.bootstrap = {"initdb": {
              "database": $c.spec.bootstrap.recovery.database,
              "owner": $c.spec.bootstrap.recovery.owner
            }}
          | del(.spec.externalClusters)
        ' \
      | kubectl -n "{{ ns }}" apply --server-side --force-conflicts -f -

    kubectl -n "{{ ns }}" wait cluster "${seed}" --for=condition=Ready --timeout=10m

    just log info "Triggering initial base backup" "namespace" "{{ ns }}" "backup" "${backup}"
    BACKUP="${backup}" SEED="${seed}" yq -n '{
        "apiVersion": "postgresql.cnpg.io/v1",
        "kind": "Backup",
        "metadata": {"name": strenv(BACKUP)},
        "spec": {
          "cluster": {"name": strenv(SEED)},
          "method": "plugin",
          "pluginConfiguration": {"name": "barman-cloud.cloudnative-pg.io"}
        }
      }' \
      | kubectl -n "{{ ns }}" apply --server-side -f -

    while true; do
      phase="$(kubectl -n "{{ ns }}" get backup "${backup}" -o jsonpath='{.status.phase}')"
      case "${phase}" in
        completed) break ;;
        failed) just log fatal "Backup failed" "namespace" "{{ ns }}" "backup" "${backup}" ;;
        *) just log info "Waiting for backup..." "backup" "${backup}" "phase" "${phase:-pending}"; sleep 10 ;;
      esac
    done

    just log info "Object store seeded, push the branch and let Flux create the cluster" "namespace" "{{ ns }}" "cluster" "${cluster}"
