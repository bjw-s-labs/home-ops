# Repository structure

The Git repository contains the following directories under [`cluster`](https://github.com/bjw-s/k8s-gitops/tree/main/cluster){target=_blank} and are ordered below by how Flux will apply them.

```
./cluster
├── ./apps
├── ./base
├── ./core
└── ./crds
```

- [**`base`**](https://github.com/bjw-s/k8s-gitops/tree/main/cluster/base){target=_blank} directory is the entrypoint to Flux
- [**`crds`**](https://github.com/bjw-s/k8s-gitops/tree/main/cluster/crds){target=_blank} directory contains custom resource definitions (CRDs) that need to exist globally in my cluster before anything else exists
- [**`core`**](https://github.com/bjw-s/k8s-gitops/tree/main/cluster/core){target=_blank} directory (depends on **crds**) are important infrastructure applications that should never be pruned by Flux
- [**`apps`**](https://github.com/bjw-s/k8s-gitops/tree/main/cluster/apps){target=_blank} directory (depends on **core**) is where my common applications (grouped by namespace) are placed. Flux will prune resources here if they are not tracked by Git anymore.
