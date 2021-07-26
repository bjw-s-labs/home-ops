# Backups

{% import 'links.md.include' as links %}

Backups of the data that lives inside my cluster are handled by {{ links.external('kasten') }}. This is a commercial backup solution, but is free to use for up to 10 nodes. Please see their website to see if your use case falls under the license agreement.

## Kasten documentation

Others have detailed this tool much better than I can, so I am going to be a bit lazy and just dump a few links here.

- [How to configure Kasten K10 Disaster Recovery](https://docs.kasten.io/latest/operating/dr.html){target=_blank}
- [Kasten K10 documentation](https://docs.kasten.io/latest/index.html){target=_blank}
- [A hands-on lab that goes through the steps of backing up and restoring an application](https://www.kasten.io/kubernetes-lab){target=_blank}

## How I back up my data

If you have gotten this far, you will now know that K10 introduces the concepts of Profiles and Policies. In summary, a Profile tells K10 _where_ to store the data, and a Policy tells it _what_ you want to back up.

My current setup is that I have a single Profile ({{ links.repoUrl('link', 'blob/main/cluster/apps/system-kasten/k10/profiles/nfs.yaml') }}) pointing to an NFS server.

I then have a single Policy ({{ links.repoUrl('link', 'blob/main/cluster/apps/system-kasten/k10/policies/apps.yaml') }}) that schedules snapshots and exports for:

- a set of namespaces
- all persistentVolumeClaim resources
- that have been assigned the label `kasten.io/backup-volume: "true"`

## Restoring PVCs using Kasten

Recovering from a K10 backup involves the following sequence of actions:

### 1. Create a Kubernetes Secret, k10-dr-secret, using the passphrase provided while enabling DR

```sh
kubectl create secret generic k10-dr-secret \
    --namespace system-kasten \
    --from-literal key=<passphrase>
```

### 2. Install a fresh K10 instance

!!! info "Ensure that Flux has correctly deployed K10 to it's namespace `system-kasten`"

### 3. Provide NFS information and credentials for the snapshot export location

!!! info "Ensure that Flux has correctly deployed the `nfs` storage profile and that it's accessible within K10"

### 4. Restoring the K10 backup

Install the helm chart that creates the K10 restore job and wait for completion of the `k10-restore` job

```sh
helm install k10-restore kasten/k10restore --namespace=system-kasten \
    --set sourceClusterID=<source-clusterID> \
    --set profile.name=<location-profile-name>
```

### 5. Application recovery

Upon completion of the DR Restore job, go to the Applications card, select `Removed` under the `Filter by status` drop-down menu.

Click restore under the application and select a restore point to recover from.
