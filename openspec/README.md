# OpenSpec in Home Ops

OpenSpec records infrastructure behavior and proposed changes. Manifests remain
the implementation; `AGENTS.md` remains the canonical repository policy.

## Layout

- `config.yaml`: project planning constraints and artifact-specific rules.
- `specs/<capability>/spec.md`: durable capability requirements and scenarios.
- `changes/<change>/`: proposals, spec deltas, designs, and implementation tasks.
- `changes/archive/`: completed changes retained as history.

The initial `gitops-deployment` spec is a repository-derived baseline, not a new
deployment or proof of current runtime behavior. It was seeded directly as an
existing capability; no fictional implementation change or archive was created.

## Working on a Change

Run CLI commands from the repository root with its mise-managed OpenSpec tool.

1. Read `AGENTS.md`, relevant specs, configuration, and applicable task guidance.
2. Explore the outcome and scope with `/openspec-explore` if needed.
3. Use `/openspec-propose` to create a named change and its planning artifacts.
4. Review the proposal, delta scenarios, design, and tasks before implementation.
5. Use `/openspec-apply-change` in a subsequent request to implement approved scope.
6. Validate the change, review the diff, and complete any separately approved
   operational validation. Archive with `/openspec-archive-change` when complete.

Useful CLI checks:

```sh
openspec list --json
openspec list --specs --json
openspec show gitops-deployment --type spec
openspec validate --all --strict --no-interactive
```

For manual scaffolding, use `openspec new change <name>`, then follow
`openspec status --change <name> --json` and
`openspec instructions <artifact> --change <name> --json` rather than inventing
artifact formats or creating a change directory by hand. A CLI scaffold alone
is not a completed proposal. Validate an individual change with
`openspec validate <name> --strict --no-interactive`.

Artifact completion and successful OpenSpec validation do not prove that a
manifest renders correctly or that a deployment succeeded. Apply the relevant
repository validation from `AGENTS.md`, and report local and runtime results
separately. OpenSpec commands do not grant approval to merge, reconcile, or
change live infrastructure.

## Growing the Baseline

Start with behavior needed for the next meaningful change rather than a spec
per app or manifest. Candidate future capabilities are cluster lifecycle,
workload management, storage and backups, and host operations. These are
candidates only; their requirements have not been established here.

For each additional baseline:

1. Trace the relevant source, consumers, operational recipes, and existing tests.
2. Write observable requirements with concrete scenarios, not a YAML inventory.
3. Add evidence paths and explicit verification limits.
4. Review ambiguous intent rather than promoting every current value to policy.
5. Run strict OpenSpec validation and check references.

Preserve existing capability paths. For future behavior changes, use spec deltas
inside a change; archive merges those deltas into the durable specs. Keep
component-specific runbooks beside their configuration instead of copying them
into OpenSpec.

## Source and Bootstrap Boundary

Forgejo at `https://git.bjw-s.dev/bjw-s/home-ops.git` is the authoritative
repository. It is mirrored to `https://github.com/bjw-s-labs/home-ops.git`, which
is the source configured for Flux. The operator confirmed this architecture:
GitHub keeps manifests accessible during bootstrap or recovery when the cluster
and its Forgejo service are not operational yet.

The different URLs are intentional, not configuration drift. Before declaring a
deployment complete, verify that the intended Forgejo commit reached the GitHub
revision consumed by Flux, then verify Flux observed that revision. This setup
does not verify current mirror health or live Flux status.
