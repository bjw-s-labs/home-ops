# GitOps

[Flux](https://github.com/fluxcd/flux2) watches my [kubernetes](https://github.com/bjw-s-labs/home-ops/tree/main/kubernetes/) folder (see [Directory structure](#directory-structure)) and makes the changes to my cluster based on the YAML manifests.

The way Flux works for me here is it will recursively search the [kubernetes/apps](https://github.com/bjw-s-labs/home-ops/tree/main/kubernetes/main/apps) folder until it finds the most top level `kustomization.yaml` per directory and then apply all the resources listed in it. That aforementioned `kustomization.yaml` will generally only have a namespace resource and one or many Flux kustomizations. Those Flux kustomizations will generally have a `HelmRelease` or other resources related to the application underneath it which will be applied.

[Renovate](https://github.com/renovatebot/renovate) watches my **entire** repository looking for dependency updates, when they are found a PR is automatically created. When PRs are merged [Flux](https://github.com/fluxcd/flux2) applies the changes to my cluster.

## Directory structure

My home-ops repository contains the following directories under [kubernetes](https://github.com/bjw-s-labs/home-ops/tree/main/kubernetes/).

```sh
📁 kubernetes      # Kubernetes clusters defined as code
├─📁 main     # My main kubernetes cluster
│ ├─📁 bootstrap   # Flux installation
│ ├─📁 flux        # Main Flux configuration of repository
│ └─📁 apps        # Apps deployed into my cluster grouped by namespace (see below)
└─📁 tools         # Manifests that come in handy every now and then
```

## Flux resource layout

Below is a a high level look at the layout of how my directory structure with Flux works. In this brief example you are able to see that `authelia` will not be able to run until `glauth` and `cloudnative-pg` are running. It also shows that the `Cluster` custom resource depends on the `cloudnative-pg` Helm chart. This is needed because `cloudnative-pg` installs the `Cluster` custom resource definition in the Helm chart.

```python
# Key: <kind> :: <metadata.name>
GitRepository :: home-ops-kubernetes
    Kustomization :: cluster
        Kustomization :: cluster-apps
            Kustomization :: cluster-apps-authelia
                DependsOn:
                    Kustomization :: cluster-apps-glauth
                    Kustomization :: cluster-apps-cloudnative-pg-cluster
                HelmRelease :: authelia
            Kustomization :: cluster-apps-glauth
                HelmRelease :: glauth
            Kustomization :: cluster-apps-cloudnative-pg
                HelmRelease :: cloudnative-pg
            Kustomization :: cluster-apps-cloudnative-pg-cluster
                DependsOn:
                    Kustomization :: cluster-apps-cloudnative-pg
                Cluster :: postgres
```
