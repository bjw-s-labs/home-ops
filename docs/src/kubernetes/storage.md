# Storage

Storage in my cluster is handled in a number of ways.
The in-cluster storage is provided by a [rook](https://github.com/rook/rook) Ceph cluster that is running on a number of my nodes.

## rook-ceph block storage

The bulk of my cluster storage relies on [my `CephBlockPool`](https://github.com/bjw-s-labs/home-ops/tree/main/kubernetes/main/apps/rook-ceph/rook-ceph/cluster]). This ensures that my data is replicated across my storage nodes.

## NFS storage

Finally, I have my NAS that exposes several exports over NFS. Given how NFS is a very bad idea for storing application data (see for example [this Github issue](https://github.com/Sonarr/Sonarr/issues/1886)) I only use it to store data at rest, such as my personal media files, Linux ISO's, backups, etc.
