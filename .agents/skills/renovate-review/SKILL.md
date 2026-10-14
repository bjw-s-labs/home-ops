---
name: renovate-review
description: Review Renovate dependency updates in this Flux/GitOps home-ops repository, including Helm OCI charts, container tags/digests, Talos/Kubernetes, GitHub Actions, Terraform/OpenTofu, Docker Compose, and Renovate presets. Investigate rendered impact, upstream changes and actual repository dependencies before recommending a merge.
---

# Review a Renovate PR in home-ops

Determine **what changes on deployment and whether this repository relies on the old behavior**. Flux can reconcile `kubernetes/` changes soon after merge. This skill is loaded by the AI PR Review workflow for `renovate/*` branches; it adds repository-specific investigation steps to the bundled reviewer. The repository's **trusted `AGENTS.md` standards remain authoritative**.

## 1. Establish the update and deployment footprint

- Identify every dependency and old/new version, digest or chart tag. Renovate groups may contain several independent upgrades. A shared base under `kubernetes/apps/base/<namespace>/<app>/` can deploy to **main, utility and/or test** via overlays in `kubernetes/apps/<cluster>/`; look for every consuming overlay before judging impact.
- Distinguish **OCIRepository chart tag** updates, **container image/digest** updates, **HelmRelease values** changes, **Talos/Kubernetes** upgrades, **GitHub Actions**, **OpenTofu providers/modules**, **Docker Compose** and Renovate configuration. An OCI chart is pinned by `ref.tag` rather than a container-style `@sha256:` digest. Do not flag that as missing image pinning.
- The actual rendered resources, not the one-line git diff, determine most Helm/Flux compatibility risks.

## 2. Inspect the rendered change (when applicable)

The reviewer is configured with the **Konflate evidence provider and read-only MCP tools**, rather than the upstream example repository's `flate` setup. Prefer evidence already included in the review corpus:

- `mcp__konflate__get_pr_summary` with this PR number: affected resources and clusters, additions/removals, image changes, data-loss, immutable field, RBAC, `suspend`/`prune`, and render errors.
- `mcp__konflate__get_pr_diff` with this PR number when chart defaults, templates, selectors or Helm values could change rendered manifests while the git diff looks trivial.
- `mcp__konflate__list_pull_requests` only if necessary to establish whether this PR has render evidence. If Konflate did not render it, say **unverified**, never "unchanged" or "safe".
- For a local manual investigation the repository documents `flate diff all --path ./kubernetes/clusters/<cluster> --base origin/main`; do **not** claim to have run this command unless an independently allowed tool actually did. A SKILL.md does **not** grant shell or Kubernetes execution rights.

Pay special attention to changes in resource names, label **values** as well as keys, selectors, ports, services, RBAC, storage classes, CRDs, probes, immutable fields and persistent-volume behavior. Konflate may omit CRDs/Secret data; their absence from a render is not evidence of no change. One unrelated rendering failure is not proof that the upgraded chart fails.

For a digest-only container refresh with unchanged repository/tag, a rendered digest change plus consistent upstream metadata is usually enough: don't invent Kubernetes breaking changes.

## 3. Verify upstream changes

Begin with the PR's Release Notes, but inspect upstream when absent, truncated, a major/0.x-minor bump, a jump across multiple versions, or a chart/image with material runtime changes. **For Helm charts and images, `AGENTS.md` requires real upstream evidence via available read-only tools**, not just the Renovate description.

- **OCI chart:** Find its source in the app's `ocirepository.yaml`, follow the publisher's chart releases/templates and compare versions. For mirrored `ghcr.io/home-operations/charts-mirror/<chart>`, use `home-operations/charts-mirror` metadata to locate the real chart source. When the chart's `appVersion` changes, inspect the underlying application's release notes too.
- **Container image:** Resolve upstream from the image owner or `org.opencontainers.image.source` metadata. For `ghcr.io/home-operations/*`, also inspect `home-operations/containers` build definitions/history for digest-only changes. Check image revision/source/created metadata when available.
- **Talos / Kubernetes:** Check each affected cluster's `talos/<cluster>/machineconfig.yaml.j2` installer image and the `TalosUpgrade`/`KubernetesUpgrade` resources managed by tuppr. Verify the **specific Talos release supports the target Kubernetes version** against the published Sidero/Talos compatibility matrix before concluding compatibility. A patch bump alone is not proof.
- **GitHub Action / Renovate preset / OpenTofu:** Read the upstream release/compare, then verify this repository's `.github/workflows/` inputs/outputs, `.renovate/` rules, `terraform/` constraints/state/migrations, or `docker/` runtime configuration as applicable.
- Follow referenced upstream issues/PRs when a changelog only says "See #123". Don't infer changed defaults or a migration solely from a release-note headline.

Check raised minimum versions, removed APIs or fields, changed auth/storage/network defaults, one-way migrations, and security advisories relevant to the deployed configuration. If an upstream source cannot be verified, label the evidence gap honestly.

## 4. Search for repository-specific exposure

Search the **actual consumers** of anything removed or renamed, not just whether the new value is explicitly set:

- Under `kubernetes/`, inspect selectors and labels in Prometheus/ServiceMonitors, alerts and dashboards, NetworkPolicies, HTTPRoutes/Gateway policies, PDBs, Flux `dependsOn`/`healthChecks`, `values`/`valuesFrom`/`postRenderers`, service DNS and CRD instances.
- Trace base-to-overlay usage across **main / utility / test**. Cilium, Envoy Gateway, external-secrets, Rook/Ceph, PostgreSQL and storage-provider updates merit close inspection for compatibility and data safety where affected.
- For `app-template` or shared chart changes, look for multiple affected HelmReleases. Chart defaults can change even when values in this repo do not.
- In `terraform/`, `ansible/`, `docker/`, `.github/` and `.renovate/`, search the corresponding consumers rather than assuming everything is a Kubernetes release.

A documented home-ops convention is **not** a finding. In particular, `metadata.namespace` intentionally comes from namespace overlays/replacements, not inline on HelmReleases or Flux Kustomizations, and OCI chart tags are not container image digests. Existing exceptions in `AGENTS.md` remain valid.

## 5. Verdict and evidence

- Respect `AGENTS.md` and the reviewer's deterministic `must_check` requirements. Do not replace or weaken review gates. A breaking change with **no affected consumer in this repository** is a brief observation, not an invented blocker.
- A finding must identify the **changed line**, the **affected consumer/path**, the concrete failure mode, and supporting rendered or upstream evidence. Confirm a replacement name/value from upstream manifests rather than guessing an auto-fix.
- Escalate documented risks: unsupported Talos/Kubernetes pairings, CRD/schema incompatibilities, data-loss/storage mutations, new security relaxations, unexpected suspend/prune, and resource/selector renames that break live consumers. For uncertain evidence, report **Unknown / needs verification** instead of asserting a failure or successful test.
- For an ordinary same-tag digest refresh, keep the review **compact**: recommendation, what changed, and any meaningful caveat. Skip empty Standards Compliance, Linked Issue Fit, Tool Harness or evidence sections, and don't dump internal planner diagnostics.
- No fabricated Konflate results, upstream comparisons, tool calls or post-merge checks. A skill describes how to review; **only configured tools may be used**, and nothing here authorizes shell commands or writes.
