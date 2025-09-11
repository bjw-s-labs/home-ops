---
applyTo: "kubernetes/apps/**/helmrelease.yaml"
---

# Instructions for HelmRelease files

## HelmReleases based on app-template

This section gives instructions specifically for HelmReleases that are based on the `app-template` chart. These can be identified by the presence of a sidecar `ocirepository.yaml` file that references `oci://ghcr.io/bjw-s-labs/helm/app-template` in the `url` field.

### Sorting rules
Whenever asked to sort these files, follow these instructions:

- Whenever there is an `enabled` field, it should be the first field within its section.

- The items within the `spec` section should be sorted as follows:
  - `chartRef`
  - `interval`
  - `dependsOn`
  - `install`
  - `upgrade`
  - `values`

- Items within the `spec.values` sections should be sorted as follows:
  - `defaultPodOptions`
  - Any other fields should be added next in alphabetical order.

### Detailed sorting rules for nested sections

- Items within the `spec.values.controllers.*` sections should be sorted as follows:
  - `pod`
  - Any other fields should be added next in alphabetical order.
  - `initContainers`
  - `containers`

- Items within `spec.values.controllers.*.containers.*` sections should be sorted as follows:
  - `image`
  - Any other fields should be added next in alphabetical order.

- Items within `spec.values.controllers.*.containers.resources` and `spec.values.controllers.*.initContainers.resources` sections should be sorted as follows:
  - `requests`
  - `limits`

- Items within `spec.values.service.*` sections should be sorted as follows:
  - `type`
  - Any other fields should be added next in alphabetical order.

- Items within `persistence.*` sections should be sorted as follows:
  - `type`
  - Any other fields should be added next in alphabetical order.
  - `globalMounts`
  - `advancedMounts`
