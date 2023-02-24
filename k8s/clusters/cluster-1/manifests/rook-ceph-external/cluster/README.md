Make sure prometheus endpoint is enabled in proxmox via 

```bash
ceph mgr module enable prometheus
```

To get the secrets, run
```bash
python3 create-external-cluster-resources.py \
--rbd-data-pool-name ceph_ssd \
--namespace rook-ceph-external \
--format bash
 ```

Run `create-secrets.sh` to create the secret file. Dont forget to encrpyt it with SOPS


To enable the dashboard

Run on all nodes
```
apt install ceph-mgr-dashboard ceph-mgr ceph-mgr-cephadm ceph-mgr-diskprediction-local ceph-mgr-ssh ceph-mgr-cephadm
```
Then run this on a single node
```
ceph mgr module enable dashboard
ceph dashboard set-rgw-api-ssl-verify False
```

Destory and recreate the managers from the PVE UI!

It takes a bit to get everything started.
Run to check for services
```
user@pve01: sudo ceph mgr services
{
    "dashboard": "https://10.200.40.21:8443/",
    "prometheus": "http://10.200.40.21:9283/"
}
```
For object gateway dashboard to work
https://docs.ceph.com/en/latest/mgr/dashboard/#enabling-the-object-gateway-management-frontend

```
radosgw-admin user create --uid=dashboard --display-name=dashboard --system
```
Record the access & secret keys
Place each key into a text file
```
sudo ceph dashboard set-rgw-api-access-key -i access-key
sudo ceph dashboard set-rgw-api-secret-key -i secret-key
```


## Create erasure coded pools
More commands and options listed
https://pve.proxmox.com/pve-docs/pveceph.1.html

```
pveceph pool create ssd-erasure-coded-backups --application cephfs --erasure-coding k=4,m=2,,device-class=ssd,failure-domain=osd,profile=ssd-erasure-coded
```

## NFS-Genesha

On All Nodes
```
sudo apt install nfs-ganesha nfs-ganesha-ceph nfs-ganesha-vfs
```