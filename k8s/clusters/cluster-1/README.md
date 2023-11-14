## cluster-1

cluster-1 is my homeprod cluster.

## How to bootstrap

Assuming you are in the `cluster-1` root folder:

### Flux

#### Install Flux

```sh
kubectl apply --server-side --kustomize ./bootstrap
```

### Apply Cluster Configuration

_These cannot be applied with `kubectl` in the regular fashion due to some files being encrypted with sops_

```sh
sops --decrypt ./bootstrap/age-key.sops.yaml | kubectl apply -f -
# kubectl apply -f ./flux/vars/cluster-settings.yaml
```

### Kick off Flux applying this repository. Assuming I am in the cluster-1 folder. This command targets the kustomization.yaml file in the same folder as the deploy-cluster.yaml

```sh
kubectl apply --server-side --kustomize . 
```
