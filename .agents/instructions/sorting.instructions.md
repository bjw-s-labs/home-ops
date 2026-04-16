# Sorting instructions for all yaml files

Whenever asked to sort these files, follow these instructions:

- **Default rule**: All fields and properties should be sorted alphabetically at every level of the YAML structure, regardless of how deeply nested they are, unless a specific override rule is provided below or in other applicable instructions files.

## Override rules for Kubernetes related file types

- Whenever they are present on the same level of a YAML structure, these fields should be sorted as follows:
  - `apiVersion`
  - `kind`
  - `metadata`
  - `spec`

- The items within the `metadata` section should be sorted as follows:
  - `name`
  - `namespace`
  - `annotations`
  - `labels`

## HelmReleases based on app-template

This section gives instructions specifically for HelmReleases that are based on the `app-template` chart. These can be identified by the presence of a sidecar `ocirepository.yaml` file that references `oci://ghcr.io/bjw-s-labs/helm/app-template` in the `url` field.

### Sorting rules
Whenever asked to sort these files, follow these instructions:

- Whenever there is an `enabled` field, it should be the first field within its section, unless a more specific rule below dictates otherwise.

- The items within the `spec` section should be sorted as follows:
  - `chartRef`
  - `interval`
  - `dependsOn`
  - `install`
  - `upgrade`
  - `values`

- Items within the `spec.values` section should be sorted as follows:
  - `defaultPodOptions` (if present)
  - All sibling keys at the `spec.values` level should be sorted alphabetically (e.g., `controllers`, `persistence`, `route`, `service`)

Note: Sibling keys within `persistence.*`, `service.*`, `route.*`, `configMaps.*`, etc. are NOT required to be sorted - only the keys within each individual item. For example, if `persistence` has `config`, `data`, and `tmpfs` as children, they can be in any order. Only the keys within `persistence.config`, `persistence.data`, etc. should be sorted.

**Important:** The sorting rules apply to the HelmRelease structure itself. Do NOT sort arbitrary YAML content embedded within string fields (e.g., `configMap.data.*` values containing YAML configurations).

### General pattern for section keys

Unless a more specific rule applies, keys within any section should be ordered as:
- `annotations` (if present)
- `labels` (if present)
- All other keys should be sorted alphabetically

### Detailed sorting rules for nested sections

- Items within the `spec.values.controllers.*` sections should be sorted as follows:
  - `type` (if present, always first)
  - `annotations` (if present)
  - `labels` (if present)
  - Controller-specific fields such as `cronjob` or `statefulset` (if present)
  - `pod`
  - Any other fields should be sorted alphabetically, except the following fields which should come last (and in this order):
  - `initContainers` (if present)
  - `containers` (if present)

- Items within `spec.values.controllers.*.containers.*` sections should be sorted as follows:
  - `image`
  - Any other fields should be added next in alphabetical order.

- Items within `spec.values.controllers.*.containers.resources` and `spec.values.controllers.*.initContainers.resources` sections should be sorted as follows:
  - `requests`
  - `limits`

- Items within `spec.values.service.*` sections should be sorted as follows:
  - `type` (if present)
  - `annotations` (if present)
  - `labels` (if present)
  - Any other fields should be added next in alphabetical order.

- Items within `persistence.*` sections should be sorted as follows:
  - `type` (if present)
  - `annotations` (if present)
  - `labels` (if present)
  - Any other fields should be sorted alphabetically, except the following fields which should come last (and in this order):
  - `globalMounts` (if present)
  - `advancedMounts` (if present)

### Quick reference

**Before sorting, verify the chart is app-template based:**
1. Check for a sidecar `ocirepository.yaml` file
2. Confirm the `url` field contains `oci://ghcr.io/bjw-s-labs/helm/app-template`
3. If not app-template, do not apply these sorting rules

**Decision tree for sorting HelmRelease fields:**

```
At spec.values level?
  → Yes: defaultPodOptions first (if present), then alphabetical
  
Within controllers.*.containers.* or .initContainers.*?
  → Yes: image first, then alphabetical
  
Within persistence.*, service.*, etc. siblings?
  → No: Do not sort siblings (e.g., persistence.config vs persistence.data order doesn't matter)
  → Yes: Sort keys within each item (type → annotations → labels → alphabetical)
