# Start new cluster

```sh
export CONTEXT='cluster-2'
```

1. Bootstrap etcd for a new cluster

```sh
talosctl bootstrap --nodes cp1.$CONTEXT.elcarpenter.com --endpoints $CONTEXT.elcarpenter.com --context $CONTEXT
```

2. Install CNI

```sh
kubectl --context $CONTEXT kustomize --enable-helm ./integrations/cni | kubectl --context $CONTEXT apply -f - 
```

3. Install CSR approver

```sh
kubectl --context $CONTEXT kustomize --enable-helm ./integrations/kubelet-csr-approver | kubectl --context $CONTEXT apply -f - 
```
