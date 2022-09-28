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
