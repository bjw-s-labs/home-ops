## cluster-0

cluster-0 is my homeprod cluster.

### How to bootstrap

Assuming you are in the `cluster-0` root folder:

```console
kubectl apply -k .
```

Don't forget to apply the `sops-age` Secret that allows Flux to decrypt encrypted files!
