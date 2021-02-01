# Shrinking a cluster

This document describes the method for shrinking a cluster, by removing a
worker nodes.

## Assumptions

It is assumed that you have already deployed a k3s cluster using this role,
you have an appropriately configured inventory and playbook to create the
cluster.

Below, our example inventory and playbook are as follows:

  - inventory: `inventory.yml`
  - playbook: `cluster.yml`

Currently your `inventory.yml` looks like this, it has three nodes defined,
`kube-0` (control node) and `kube-1`, `kube-2` (worker nodes).

```yaml
---

k3s_cluster:
  hosts:
    kube-0:
      ansible_user: ansible
      ansible_host: 10.10.9.2
      ansible_python_interpreter: /usr/bin/python3
    kube-1:
      ansible_user: ansible
      ansible_host: 10.10.9.3
      ansible_python_interpreter: /usr/bin/python3
    kube-2:
      ansible_user: ansible
      ansible_host: 10.10.9.4
      ansible_python_interpreter: /usr/bin/python3
```

## Method

We have our three nodes, one control, two workers. The goal is to shrink this to
remove excess capacity by offboarding the worker node `kube-2`. To do this we
will set `kube-2` node to `k3s_state: uninstalled` in our inventory.

```yaml
---

k3s_cluster:
  hosts:
    kube-0:
      ansible_user: ansible
      ansible_host: 10.10.9.2
      ansible_python_interpreter: /usr/bin/python3
    kube-1:
      ansible_user: ansible
      ansible_host: 10.10.9.3
      ansible_python_interpreter: /usr/bin/python3
    kube-2:
      ansible_user: ansible
      ansible_host: 10.10.9.4
      ansible_python_interpreter: /usr/bin/python3
      k3s_state: uninstalled
```

What you will typically see is changes to your control plane (`kube-0`) and the
node being removed (`kube-2`). The role will register the removal of the node
with the cluster by draining the node and removing it from the cluster.

```text
PLAY RECAP *******************************************************************************************************
kube-0                     : ok=55   changed=2    unreachable=0    failed=0    skipped=28   rescued=0    ignored=0
kube-1                     : ok=40   changed=0    unreachable=0    failed=0    skipped=35   rescued=0    ignored=0
kube-2                     : ok=23   changed=2    unreachable=0    failed=0    skipped=17   rescued=0    ignored=1
```
