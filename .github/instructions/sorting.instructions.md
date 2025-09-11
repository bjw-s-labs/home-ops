---
applyTo: "**/*.yaml"
---

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
