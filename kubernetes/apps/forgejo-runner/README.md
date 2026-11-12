# Forgejo runner isolation and namespace cutover

The runner controller, Kubernetes plugin, and transient workflow Jobs live in
`forgejo-runner`. Forgejo, its Valkey instance, signing/OAuth credentials, and
persistent data remain in `dev`. This is a namespace/RBAC separation, not a
sandbox for hostile code or a move to dedicated compute.

## Security and compatibility review

- **Ownership:** `flux-system/cluster-apps` discovers this namespace directory
  and creates its Namespace, Flux alerts, and `forgejo-runner/forgejo-runner`
  Kustomization. The latter owns the ExternalSecret, OCIRepository, HelmRelease,
  and CiliumNetworkPolicy. Helm owns the Deployment, ConfigMap, ServiceAccount,
  Role, and RoleBinding. Runtime Jobs are created by the plugin, not Flux/Helm.
  The namespace component disables Namespace pruning, including on rollback.
- **RBAC:** the existing Role verbs are retained, but apply only inside
  `forgejo-runner`. The controller no longer has its old RoleBinding's ability
  to exec into Forgejo/Kritika pods or create Jobs in `dev`. No ClusterRole or
  cross-namespace binding is added. Job creation can indirectly consume any
  Secret or ServiceAccount in the same namespace; do not place unrelated
  credentials or privileged service accounts here. Separation does not protect
  the runner registration Secret from a compromised controller in its own
  namespace.
- **Job identities:** jobs use the destination namespace's default ServiceAccount,
  not the controller's `forgejo-runner` ServiceAccount. Both configured PodSpecs
  explicitly disable token automount. The controller retains its token because
  the plugin calls the Kubernetes API, including GET/POST `pods/exec`. Arbitrary
  workflow-supplied PodSpecs need a separate admission design if they must be
  constrained beyond these administrator-managed templates.
- **PSS/PSA:** the namespace declares `pss.policy.bjw-s.dev/baseline: audit`,
  matching the repository's opt-down convention. The cluster admission policy
  adds baseline audit rather than baseline enforcement for this new namespace.
  This is necessary for the existing privileged `docker:29-dind` native sidecar;
  baseline/restricted enforcement would reject it. Do not weaken `dev` or set
  admission provenance labels in Git. Namespace audit-only behavior applies to
  the controller too, and is not container-specific. Verify the admitted labels
  at rollout; source rendering alone cannot exercise admission.
- **Actual job namespace:** Runner 13.2.1 uses `plugins.k8s.options.namespace`.
  The old top-level `kubernetes` block is not a Runner 13.2.1 config field and
  was ignored. It has been removed rather than preserved with another value.
  Existing jobs ran in `dev`, not the obsolete block's `forgejo` value.
- **Job egress:** the moved policy explicitly selects Forgejo in `dev` on TCP
  3000. Controller/cache endpoint selectors remain namespace-local because both
  sides move together. Model egress targets Agent Gateway (`ai`, TCP 8080); Konflate
  (`flux-system`, TCP 8080), external Envoy (`network`), and Internet HTTP/HTTPS
  remain allowed. Clusterwide DNS egress still applies. The job's `block-all`
  label excludes the broad default-egress policy; Cilium's clusterwide policy
  repository implements policies additively, so the empty egress rule contributes
  no allow and the endpoint remains default-denied except for matching allow
  rules. No job Kubernetes-API egress is added. Forgejo's existing ingress
  permits TCP 3000 from all sources. LiteLLM and Konflate ingress effects were
  not confirmed from authoritative complete policy sources; verify those
  endpoints during the smoke test.
- **Controller traffic:** the existing broad default-egress policy still covers
  the controller, including API access and Forgejo. Its cache/proxy remains
  reachable from jobs. Moving namespaces does not itself restrict controller
  egress or ingress. Cache URLs advertise the runner pod IP, not a `dev` DNS
  name, and cache state is process-local. No new Service, route, DNS entry,
  certificate, Gateway grant, or storage is needed.
- **Ingress:** the job policy retains its existing `enableDefaultDeny.ingress`
  setting but contains no ingress rules. Cilium 1.20.4 only creates internal
  ingress policy entries from actual ingress rules; the clusterwide policy here
  contributes egress entries only. Therefore these policies do not establish
  ingress isolation for runner jobs. This migration does not add a new ingress
  hardening policy; separately design and validate one if job-to-job ingress
  isolation is required.
- **Stale callback allowance:** TCP 38809 is removed. This pinned plugin uses a
  Unix gRPC socket with the daemon and API-server exec transport to Jobs; it
  does not expose a controller callback listener on that port. Cache TCP
  8088/8089 remains allowed.
- **Secrets:** the same ExternalSecret definition reads the existing 1Password
  runner item and produces `forgejo-runner-secret` in the new namespace. The
  ClusterSecretStore has no namespace condition blocking this destination.
  No secret value is copied through Git, rotated, or re-registered. Do not run
  old and new controllers concurrently with the same registration identity.
- **Storage, capacity, and scheduling:** the runner's `/data` (including its
  cache) uses a 50Gi PVC on the Samsung-backed `miroir-local-slow` class and
  persists across runner pod replacements; `/tmp` remains `emptyDir`. Each
  DinD job gets a separate 25Gi generic ephemeral PVC for `/var/lib/docker`,
  which Kubernetes removes with the job pod. Renovate uses a 10Gi claim on the
  same class for each per-run scratch volume. These volumes are node-local and
  unreplicated; their contents are disposable. Capacity remains four CI jobs,
  plus Renovate's configured parallelism of five, so simultaneous jobs can
  request up to 200Gi on the Samsung including the runner cache claim. Miroir
  uses an LVM thin pool, so monitor physical pool and metadata usage as well as
  PVC requests. Requests/limits, images, labels, scheduling, native-sidecar
  ordering, and shutdown settings are otherwise unchanged. There was no
  applicable ResourceQuota or LimitRange in `dev`; none is silently introduced
  here. Namespace separation does not isolate CPU, memory, disk, or kernel
  contention on the shared node.
- **Other controllers:** Flux, External Secrets, reloader, log collection, and
  cluster monitoring are cluster-scoped in the reviewed setup. Flux error
  alerts are included in the new namespace. There is no runner PodMonitor or
  namespace-specific runner dashboard in this app to migrate. Existing Kritika
  validation bindings are scoped to `dev` and do not need moving.

## Cutover: approval and a quiet CI window required

This PR is not a zero-downtime relocation. Namespace changes create a new
Helm release and remove the old release. Flux may install the destination while
pruning the source; neither `dependsOn` nor a Deployment `Recreate` strategy
orders two independently named/namespaced controllers. Do not rely on pruning
to drain active workflows or serialize the cutover.

1. Before merge, obtain explicit approval for the operational cutover. Prevent
   new workflow submissions for the window and let active Forgejo tasks finish.
   Check Forgejo's active tasks as well as `dev` Jobs/Pods labelled
   `app.kubernetes.io/managed-by=forgejo-runner`; an empty pod list alone is not
   proof that the controller has no assigned task. Keep CI paused through the
   namespace and policy installation.
2. Under that approval, stop the old controller and prevent its HelmRelease from
   restoring it while the cutover is in progress. For example, suspend the old
   HelmRelease and scale its Deployment to zero as an explicitly approved,
   temporary maintenance action; these are not persistent desired-state edits.
   Verify the old controller has actually exited and its jobs are gone before
   allowing the replacement to start. A GitOps-only staged stop can be used
   instead, but must be reconciled and verified before the move is merged.
3. Merge only with approval. Allow normal GitOps reconciliation, or separately
   approve an explicit reconcile. Confirm destination Namespace admission,
   ExternalSecret Ready, Cilium policy Valid, local Role/RoleBinding subjects,
   HelmRelease Ready, and one ready destination controller. Verify the old
   Kustomization, HelmRelease, Deployment, and RoleBinding are removed from
   `dev`. Runtime jobs are not part of the old Helm release inventory and must
   be checked independently.
4. Keep general CI paused and allow only controlled smoke workflows after the
   destination network policies are installed. Exercise default and `docker`
   labels, checkout, log streaming, cancellation/cleanup, cache upload/download,
   Internet dependency access, and representative LiteLLM/Konflate workflows.
   Inspect admitted job pods: namespace, labels, token automount, ServiceAccount,
   privileged DinD, and native sidecars. Verify intended allowed flows and
   negative tests (API, Forgejo's Redis, unrelated cluster services); do not
   treat YAML rendering as a live connectivity test.
5. Check controller RBAC can create/get/delete Jobs and use `pods/exec` locally,
   cannot exec into `dev` pods, and jobs have no controller token. Confirm `dev`
   still enforces baseline, the destination uses baseline audit, and no
   unexpected admission/egress errors appear. Re-enable ordinary CI only after
   both templates pass and cleanup succeeds.

The daemon's `shutdown_timeout` is three minutes, not the three-hour job timeout.
The runner waits on active steps, after which its native plugin sidecar cleans up
its in-memory environments by deleting their Jobs. The 300-second pod
termination grace allows cleanup time but cannot preserve long workflows. A new
plugin process cannot adopt the old process's in-memory environments. Budget for
runner unavailability, cancelled/interrupted tasks, cache misses, and reruns;
Forgejo web/Git availability and persistent data should remain unaffected.

## Recovery

Keep CI paused. With explicit operational approval, stop the destination
controller and verify no destination tasks/jobs remain before restoring the
previous Git revision via a reviewed revert PR. Wait for the `dev` release and
its namespace-local RBAC/policy to return, and resume any old maintenance
suspension if necessary. Validate default-label jobs before reopening CI. The
old `dev` baseline PSS would still reject privileged DinD; do not describe a
revert as restoring Docker-job admission. The destination Namespace deliberately
survives pruning; inspect leftovers and obtain separate approval before cleanup.
No runner credential rotation or Forgejo database restore is part of rollback.

## Implementation references

Reviewed versions: Forgejo 17.0.1, Runner 13.2.1, runner-k8s-plugin 13.2.1,
app-template 5.3.0, Cilium 1.20.4, Kubernetes 1.37.1.

- [Runner configuration](https://code.forgejo.org/forgejo/runner/src/tag/v13.2.1/internal/pkg/config/config.go)
- [Plugin namespace and labels](https://git.erwanleboucher.dev/eleboucher/runner-k8s-plugin/src/tag/v13.2.1/server.go)
- [Plugin Job creation and exec](https://git.erwanleboucher.dev/eleboucher/runner-k8s-plugin/src/tag/v13.2.1/k8s_pod.go)
- [Cilium namespace selectors](https://docs.cilium.io/en/stable/security/policy/kubernetes.html#specifying-namespace-in-endpointselector-fromendpoints-toendpoints)
- [Cilium policy conversion](https://github.com/cilium/cilium/blob/v1.20.4/pkg/policy/utils/parserules.go)
- [Cilium internal peer-selector semantics](https://github.com/cilium/cilium/blob/v1.20.4/pkg/policy/types/policyentry.go)
- [Kubernetes RBAC escalation considerations](https://kubernetes.io/docs/concepts/security/rbac-good-practices/#workload-creation)
- [Flux Helm namespace changes](https://fluxcd.io/flux/components/helm/helmreleases/#target-namespace)
