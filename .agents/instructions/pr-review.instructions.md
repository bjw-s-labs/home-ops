# Home-ops PR review conventions

This file contains the general home-ops review procedure. The AI PR Review
workflow (`.forgejo/workflows/pr-reviewer.yaml`) always includes it in the
assembled `system_prompt_file`, and adds the Renovate skill for Renovate PRs.
With `system_prompt_mode: append`, the action retains its bundled review
instructions and output schema. Do not duplicate those instructions here.

## Repository policy

The repository's trusted `AGENTS.md` is the authoritative source of project
conventions and is loaded separately by CI as the standards file. Follow its
namespace, image-pinning, upstream-evidence, and task-guidance rules. Do not flag
explicitly intentional patterns as concerns or "for awareness" notes.

### Compact Renovate digest-only reviews

For Renovate digest-only container image updates where the repository and tag are unchanged and the diff only changes `@sha256:` values, keep `review_markdown` compact.

Prefer:

- short recommendation
- changed files summary
- non-blocking caveats, if any

Do not include separate Standards Compliance, Linked Issue Fit, Evidence Provider Findings, Tool Harness Findings, or Unknowns sections unless they contain an actual warning or blocker.

Do not include internal planner/tool-harness diagnostics such as missing `requests[]` unless they affect the recommendation.

Missing OCI revision/source labels are a non-blocking caveat for same-tag digest refreshes when repository, tag, and created timestamp evidence are consistent.

### Tool call discipline

- Supply every required argument for each tool call, using the current PR context where applicable.
- After a tool error, correct the arguments before trying again; do not repeat an identical call.
- Reuse successful tool results and stop calling tools once they provide enough evidence for the review.

### Konflate rendered-diff tools

A Konflate MCP server is configured. Konflate renders Helm charts and Kustomizations into their final Kubernetes manifests, so its rendered diff shows the actual cluster impact of a PR — not just the raw git changes. A rendered-diff summary is usually already injected into the corpus by the konflate evidence provider; use the MCP tools when you need more than the summary provides.

- `mcp__konflate__get_pr_summary` — pass the current PR `number`. Blast radius (added/changed/removed resources), caution lint (data-loss, immutable-field, RBAC, suspend/prune), image changes, render failures. Cheap and high-value; call this first if the evidence section is missing or stale.
- `mcp__konflate__get_pr_diff` — pass the current PR `number`. The full rendered manifest diff (Kubernetes YAML at PR head vs merge-base). Use it when the raw git diff hides the real change — e.g. a HelmRelease version bump or a one-line `values` change that fans out across many resources.
- `mcp__konflate__list_pull_requests` — lists the PRs konflate is tracking. If the current PR is not listed, rendered-diff evidence is unavailable; treat it as Unknown, not a clean result.

Konflate signals in the review: surface cautions as caveats or blockers by severity; treat render failures as blockers (the manifests may not apply cleanly). For Renovate digest-only bumps where konflate shows only `@sha256:` changes, keep the review compact (see above).

Check upstream for breaking changes and search this repository for affected consumers. Apply the evidence requirements in `AGENTS.md`; distinguish verified impact from unavailable evidence.
