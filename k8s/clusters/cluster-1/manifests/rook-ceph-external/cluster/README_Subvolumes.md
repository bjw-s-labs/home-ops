# Steps to create cephfs subvolume & consume it via an external Rook Ceph client

```bash
export VOL_NAME=hdd-ec-media
export SUBVOL_NAME='cache'
export SUBVOL_SIZE='500000000000'
export SUBVOL_GID=100
export SUBVOL_UID=568
export SUBVOL_FOLDER_PERMS=775
export SUBVOL_DATA_POOL_LAYOUT=

ceph fs subvolume create $VOL_NAME $SUBVOL_NAME \
    --size $SUBVOL_SIZE \
    --uid $SUBVOL_UID \
    --gid $SUBVOL_GID \
    --mode $SUBVOL_FOLDER_PERMS
    # --pool_layout $SUBVOL_DATA_POOL_LAYOUT \

ceph fs subvolume info $VOL_NAME $SUBVOL_NAME

```

Add PV & PVC. I am not sure how to add it via a storage class.
[https://github.com/ceph/ceph-csi/blob/devel/docs/static-pvc.md#create-cephfs-static-pv]

First, you need to get the subvolume root path

```bash
ceph fs subvolume getpath $VOL_NAME $SUBVOL_NAME

# Output looks something like
# /volumes/_nogroup/cache/455a9dd1-0030-44e6-9a77-7159533e860f
```

```yaml
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: cephfs-hdd-ec-media-subvolume-cache
# Change "rook-ceph" provisioner prefix to match the operator namespace if needed
provisioner: rook-ceph.cephfs.csi.ceph.com # driver:namespace:operator
parameters:
  # clusterID is the namespace where the rook cluster is running
  # If you change this namespace, also change the namespace below where the secret namespaces are defined
  clusterID: rook-ceph-external # namespace:cluster

  # CephFS filesystem name into which the volume shall be created
  fsName: hdd-ec-media

  # Ceph pool into which the volume shall be created
  # Required for provisionVolume: "true"
  # For erasure coded pools, we have to create a replicated pool as the default data pool and an erasure-coded
  # pool as a secondary pool.
  pool: hdd-ec-media-data

  # The secrets contain Ceph admin credentials. These are generated automatically by the operator
  # in the same namespace as the cluster.
  csi.storage.k8s.io/provisioner-secret-name: rook-csi-cephfs-provisioner
  csi.storage.k8s.io/provisioner-secret-namespace: rook-ceph-external # namespace:cluster
  csi.storage.k8s.io/controller-expand-secret-name: rook-csi-cephfs-provisioner
  csi.storage.k8s.io/controller-expand-secret-namespace: rook-ceph-external # namespace:cluster
  csi.storage.k8s.io/node-stage-secret-name: rook-csi-cephfs-node
  csi.storage.k8s.io/node-stage-secret-namespace: rook-ceph-external # namespace:cluster

  # (optional) The driver can use either ceph-fuse (fuse) or ceph kernel client (kernel)
  # If omitted, default volume mounter will be used - this is determined by probing for ceph-fuse
  # or by setting the default mounter explicitly via --volumemounter command-line argument.
  # mounter: kernel
reclaimPolicy: Delete
allowVolumeExpansion: true
```
