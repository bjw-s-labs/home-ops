# Extending a cluster

This document describes the method for extending an cluster with new worker
nodes.

## Assumptions

It is assumed that you have already deployed a k3s cluster using this role,
you have an appropriately configured inventory and playbook to create the
cluster.

Below, our example inventory and playbook are as follows:

  - inventory: `inventory.yml`
  - playbook: `cluster.yml`

Currently your `inventory.yml` looks like this, it has two nodes defined,
`kube-0` (control node) and `kube-1` (worker node).

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
```

## Method

We have our two nodes, one control, one worker. The goal is to extend this to
add capacity by adding a new worker node, `kube-2`. To do this we will add the
new node to our inventory.

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

Once the new node has been added, you can re-run the automation to join it to
the cluster. You should expect the majority of changes to the worker node being
introduced to the cluster.

```text
PLAY RECAP *******************************************************************************************************
kube-0                     : ok=53   changed=1    unreachable=0    failed=0    skipped=30   rescued=0    ignored=0
kube-1                     : ok=40   changed=1    unreachable=0    failed=0    skipped=35   rescued=0    ignored=0
kube-2                     : ok=42   changed=10   unreachable=0    failed=0    skipped=35   rescued=0    ignored=0
```
