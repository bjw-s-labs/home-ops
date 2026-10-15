# Repository instructions

This file is the canonical, agent-independent source of repository policy. Essential rules live here directly; do not rely on agent-specific import syntax to load them.

## Repository map

- `kubernetes/apps/<namespace>/<app>/`: application Flux Kustomizations, HelmReleases, chart sources, and configuration.
- `kubernetes/flux/cluster/`: Flux entry point and cluster-wide application patches.
- `kubernetes/components/`: reusable Kustomize components, including namespaces, CloudNativePG, and backups.
- `kubernetes/talos/`: Talos templates, node overrides, version declarations, and operational recipes.
- `kubernetes/bootstrap/`: cluster bootstrap configuration and recipes.
- `docker/` and `ansible/`: Docker-host applications and host provisioning.
- `.forgejo/workflows/`: CI and AI PR review; `.renovate/`: dependency-update presets.
- `.mise.toml`: tool versions and environment; `.justfile` and `mod.just` files: operational commands.

## Project conventions

- This repository manages live infrastructure through GitOps. Flux can reconcile changes under `kubernetes/` soon after merge. Consider rendered resources and deployment impact, not only the source diff.
- Kubernetes applications live under `kubernetes/apps/<namespace>/<app>/`. Follow existing neighboring applications rather than assuming a shared-base or multi-cluster overlay layout.
- `metadata.namespace` is intentionally omitted on application HelmReleases and Flux Kustomizations. Namespace kustomizations at `kubernetes/apps/<namespace>/kustomization.yaml` set the namespace of the Flux Kustomizations; each application's Flux Kustomization sets `spec.targetNamespace` for its deployed resources. Do not add redundant namespaces or flag their absence without checking that chain.
- Prefer immutable `@sha256:` digests for container images. OCI Helm chart sources use `OCIRepository.spec.ref.tag` or a version selector; do not apply the container-image digest convention to chart references.
- For dependency reviews, verify upstream changes using available read-only release notes, changelogs, source comparisons, or image metadata. Helm chart and container-image reviews require upstream evidence, not only Renovate's description. Report unavailable evidence as unverified; never invent tool results or compatibility claims.
- When editing YAML, read `.agents/instructions/sorting.instructions.md` and preserve its Kubernetes and app-template ordering conventions. Avoid unrelated sorting churn, and do not reorder configuration embedded in string fields.
- Application workloads normally use Flux HelmReleases with `spec.chartRef` pointing to a per-app `OCIRepository` in `ocirepository.yaml`. Follow the add-app skill for scaffolding; existing raw manifests and operator-managed resources are not automatically violations.
- Keep component-specific documentation alongside its configuration. Do not copy another home-ops repository's paths, architecture, or operational commands without checking this tree.

## Secrets and operational safety

- Never commit plaintext credentials, resolved secrets, kubeconfigs, or Talos client configuration. Kubernetes application secrets normally come from External Secrets backed by 1Password; keep secret values out of inline Helm values.
- Talos templates intentionally contain `op://` references resolved at runtime through `op inject`. Docker-host and Ansible workflows also use 1Password; follow their existing mechanisms rather than requiring Kubernetes External Secrets outside Kubernetes.
- Local template rendering can resolve real credentials. Do not include resolved output in logs, responses, or committed files.
- Treat persistent-volume changes, CloudNativePG bootstrap/recovery and object-store settings, backup policies, resource renames, and Flux `prune`/`suspend` changes as potential data-loss or availability risks. Inspect affected consumers and rendered changes before recommending them.
- CloudNativePG components live under `kubernetes/components/cnpg/`. Read the existing cluster configuration and `just k8s seed-cnpg` recipe before changing bootstrap behavior; do not replace recovery with `initdb` as a generic fix.
- Repository edits do not authorize live infrastructure changes. Do not apply, reconcile, upgrade, delete, reset, or seed infrastructure unless the user explicitly requests that operation.

## Validation

Use the repository's mise-managed tools and inspect `just --list` for available recipes. Note that `mise install` has an Ansible Galaxy post-install hook; it is not a read-only validation command.

For Kubernetes manifest changes, inspect the rendered impact when tools and network access permit:

```sh
flate test all --path ./kubernetes/flux/cluster
flate diff all --path ./kubernetes/flux/cluster --base origin/main
```

These commands may fetch upstream sources. They do not replace checking CRDs, secrets, or runtime behavior omitted from rendered output. For documentation-only changes, targeted reference and whitespace checks are sufficient. Report which checks ran and any validation gaps; do not claim an unavailable render or test passed.

For Talos/Kubernetes upgrades, read `kubernetes/talos/version.yaml` and the relevant templates/recipes. Verify the target Kubernetes version against the specific Talos release's published support matrix and cite it in reviews; an unchecked pairing is unverified, not implicitly compatible.

## Task guidance

Read the matching skill before performing these tasks:

- Add a Kubernetes application: `.agents/skills/add-app/SKILL.md`.
- Deploy or change an application on a Docker host: `.agents/skills/add-docker-app/SKILL.md`.
- Review a Renovate update: `.agents/skills/renovate-review/SKILL.md`.
- Review a pull request: also read `.agents/instructions/pr-review.instructions.md`. Renovate guidance supplements, rather than replaces, the general review procedure.

Detailed task guidance does not grant tool permissions or override repository policy. CI consumers must explicitly load the applicable guidance; Markdown references are not automatic includes.

## Instruction ownership

- Keep shared policy in this file, task workflows in `.agents/skills/`, and detailed conditional guidance in `.agents/instructions/`. Do not duplicate policy in task files.
- `CLAUDE.md` and `.claude/skills` are compatibility symlinks to the canonical instructions and skills. Keep agent-specific directories limited to adapters and configuration, not alternative copies of shared guidance.
- Keep personal model preferences, credentials, permissions, and MCP configuration in user-level configuration, synchronized through dotfiles or another user-configuration mechanism when needed across machines. The existing `.codex/config.toml` is a legacy exception pending migration to that mechanism.
