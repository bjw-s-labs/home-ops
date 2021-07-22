# Backups

Backups of the data that lives inside my cluster are handled by [Kasten K10](https://www.kasten.io){target=_blank}. This is a commercial backup solution, but is free to use for up to 10 nodes. Please see their website to see if your use case falls under the license agreement.

## Kasten documentation

Others have detailed this tool much better than I can, so I am going to be a bit lazy and just dump a few links here.

- [How to configure Kasten K10 Disaster Recovery](https://docs.kasten.io/latest/operating/dr.html){target=_blank}
- [Kasten K10 documentation](https://docs.kasten.io/latest/index.html){target=_blank}
- [A hands-on lab that goes through the steps of backing up and restoring an application](https://www.kasten.io/kubernetes-lab){target=_blank}

## How I back up my data

If you have gotten this far, you will now know that K10 introduces the concepts of Profiles and Policies. In summary, a Profile tells K10 _where_ to store the data, and a Policy tells it _what_ you want to back up.

My current setup is that I have a single Profile ([link](https://github.com/bjw-s/k8s-gitops/blob/main/cluster/apps/system-kasten/k10/profiles/nfs.yaml)) pointing to an NFS server.

I then have a single Policy ([link](https://github.com/bjw-s/k8s-gitops/blob/main/cluster/apps/system-kasten/k10/policies/apps.yaml)) that schedules snapshots and exports for:
- a set of namespaces
- all persistentVolumeClaim resources
- that have been assigned the label `kasten.io/backup-volume: "true"`
