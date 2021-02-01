# Updating k3s

## Before you start!

Ensure you back up your k3s cluster. This is particularly important if you use
an external datastore or embedded Etcd. Please refer to the below guide to
backing up your k3s datastore:

https://rancher.com/docs/k3s/latest/en/backup-restore/

Also, check your volume backups are also working!

## Proceedure

### Updates using Ansible

To update via Ansible, set `k3s_release_version` to the target version you wish
to go to. For example, from your `v1.19.3+k3s1` playbook:

```yaml
---
# BEFORE

- name: Provision k3s cluster
  hosts: k3s_cluster
  roles:
    - name: xanmanning.k3s
      vars:
        k3s_release_version: v1.19.3+k3s1
```

Updating to `v1.20.2+k3s1`:

```yaml
---
# AFTER

- name: Provision k3s cluster
  hosts: k3s_cluster
  roles:
    - name: xanmanning.k3s
      vars:
        k3s_release_version: v1.20.2+k3s1
```

### Automatic updates

For automatic updates, consider installing Rancher's
[system-upgrade-controller](https://rancher.com/docs/k3s/latest/en/upgrades/automated/)

**Please note**, to be able to update using the system-upgrade-controller you
will need to set `k3s_install_hard_links` to `true`.
