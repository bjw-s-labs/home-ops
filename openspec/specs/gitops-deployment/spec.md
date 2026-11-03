# GitOps Deployment

## Purpose

Describe the repository-defined reconciliation contract for Kubernetes applications.
This initial baseline is derived from checked-out configuration and operator-confirmed
architectural intent, not a live cluster verification. It excludes host provisioning,
full disaster recovery procedures,
controller tuning, and individual application behavior.

## Requirements

### Requirement: Keep manifest retrieval independent of in-cluster Forgejo

Forgejo SHALL remain the authoritative repository, mirrored to GitHub. Flux SHALL
retrieve manifests from the external GitHub mirror so that manifest retrieval
does not require the in-cluster Forgejo service to be operational.

#### Scenario: Retrieve manifests during bootstrap or recovery

- **GIVEN** the intended revision is available on the GitHub mirror
- **WHEN** Flux retrieves manifests while in-cluster Forgejo is unavailable
- **THEN** the configured manifest source is the external GitHub mirror
- **AND** retrieval does not depend on the in-cluster Forgejo service

#### Scenario: Verify delivery of an authoritative change

- **WHEN** a deployment from an authoritative Forgejo commit is verified
- **THEN** verification establishes that the intended commit reached the GitHub revision consumed by Flux
- **AND** verification establishes that Flux observed that revision

### Requirement: Reconcile applications through a declared source and entry point

The GitOps configuration SHALL declare a Git source, revision, and cluster entry
point, and SHALL connect that entry point to application reconciliation.

#### Scenario: Resolve the application reconciliation path

- **WHEN** the configured Flux sync entry point is evaluated
- **THEN** it includes the `cluster-apps` Flux Kustomization
- **AND** that Kustomization selects `kubernetes/apps` from the `flux-system` GitRepository

### Requirement: Resolve application namespaces through the ownership chain

Application reconciliation SHALL preserve the distinction between the namespace
of the Flux Kustomization and the target namespace of its deployed resources.
It SHALL NOT require redundant source-level namespaces on every HelmRelease.

#### Scenario: Reconcile a namespaced application

- **WHEN** a namespace Kustomize configuration includes an application's Flux Kustomization
- **THEN** the namespace configuration assigns that Flux resource's namespace
- **AND** the application's `spec.targetNamespace` selects the deployed resources' namespace

### Requirement: Include application resources explicitly

A conventionally packaged application SHALL be reachable from its namespace
configuration through a Flux Kustomization and an application Kustomize build.

#### Scenario: Include a Helm-managed application

- **WHEN** an application uses a per-application OCI chart source
- **THEN** its application Kustomize configuration includes the OCIRepository and HelmRelease
- **AND** the HelmRelease selects that chart source through `spec.chartRef`

### Requirement: Propagate shared Helm reconciliation behavior

The cluster application reconciliation configuration SHALL propagate shared
HelmRelease installation and upgrade behavior through child Flux Kustomizations.

#### Scenario: Apply shared release behavior

- **WHEN** `cluster-apps` builds child Flux Kustomizations
- **THEN** its patches configure those children to patch HelmReleases
- **AND** those HelmRelease patches define install and upgrade strategies and remediation behavior

## Baseline Evidence

These are traceability pointers, not additional requirements:

- Operator-confirmed intent: Forgejo is mirrored to GitHub to keep manifests available before the cluster is operational.
- `kubernetes/apps/flux-system/flux-instance/app/helmrelease.yaml`: sync source, revision, and entry point.
- `kubernetes/flux/cluster/kustomization.yaml`: inclusion of the cluster application Flux Kustomization.
- `kubernetes/flux/cluster/ks.yaml`: application path and shared HelmRelease patches.
- `kubernetes/apps/flux-system/kustomization.yaml`: namespace assignment and application registration.
- `kubernetes/apps/selfhosted/it-tools/ks.yaml`: representative application path and target namespace.
- `kubernetes/apps/selfhosted/it-tools/app/kustomization.yaml`: explicit application resource inclusion.
- `AGENTS.md`: canonical repository conventions and operational policy.

## Verification Limits

This baseline does not assert that the live cluster is healthy, that every
application follows the representative packaging pattern, or that the mirror is
currently synchronized. The Forgejo-to-GitHub relationship and bootstrap rationale
are operator-confirmed; current mirror delivery and the revision actually observed
by live Flux have not been verified here.
