## cluster-test

cluster-test is my home testing cluster.

### How to bootstrap

Assuming you are in the `cluster-test` root folder:

```console
kubectl apply -k .
```

Don't forget to apply the `sops-age` Secret that allows Flux to decrypt encrypted files!
