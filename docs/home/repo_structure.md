# Repository structure

{% import 'links.md.include' as links %}

The Git repository contains the following directories under {{ links.repoUrl('`cluster`', 'tree/main/cluster') }} and are ordered below by how Flux will apply them.

```console
./cluster
├── ./apps
├── ./base
├── ./core
└── ./crds
```

- {{ links.repoUrl('**`base`**', 'tree/main/cluster/base') }} directory is the entrypoint to Flux
- {{ links.repoUrl('**`crds`**', 'tree/main/cluster/crds') }} directory contains custom resource definitions (CRDs) that need to exist globally in my cluster before anything else exists
- {{ links.repoUrl('**`core`**', 'tree/main/cluster/core') }} directory (depends on **crds**) are important infrastructure applications that should never be pruned by Flux
- {{ links.repoUrl('**`apps`**', 'tree/main/cluster/apps') }} directory (depends on **core**) is where my common applications (grouped by namespace) are placed. Flux will prune resources here if they are not tracked by Git anymore.
