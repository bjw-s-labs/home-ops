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
apiVersion: v1
kind: PersistentVolume
metadata:
  name: cephfs-hdd-cache
spec:
  accessModes:
    - ReadWriteMany
  capacity:
    storage: 500G
  storageClassName: "cephfs-hdd-ec-media"
  csi:
    driver: rook-ceph.cephfs.csi.ceph.com 
    nodeStageSecretRef:
      # node stage secret name
      name: rook-csi-cephfs-node
      # node stage secret namespace where above secret is created
      namespace: rook-ceph-external 
    volumeAttributes:
      # Required options from storageclass parameters need to be added in volumeAttributes
      "clusterID": "rook-ceph-external"
      "fsName": "hdd-ec-media"
      "pool": "hdd-ec-media-data"
      "staticVolume": "true"
      "rootPath": /volumes/_nogroup/cache/455a9dd1-0030-44e6-9a77-7159533e860f
    # volumeHandle can be anything, need not to be same
    # as PV name or volume name. keeping same for brevity
    volumeHandle: cephfs-hdd-cache
  persistentVolumeReclaimPolicy: Retain
  volumeMode: Filesystem
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: cephfs-hdd-cache
  namespace: downloads
  labels:
    backup: "false"
spec:
  accessModes:
  - ReadWriteMany
  storageClassName: "cephfs-hdd-ec-media"
  resources:
    requests:
      storage: 500G
  volumeMode: Filesystem
  # volumeName should be same as PV name
  volumeName: cephfs-hdd-cache
```
