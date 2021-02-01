# Stopping and Starting a cluster

This document describes the Ansible method for restarting a k3s cluster
deployed by this role.

## Assumptions

It is assumed that you have already deployed a k3s cluster using this role,
you have an appropriately configured inventory and playbook to create the
cluster.

Below, our example inventory and playbook are as follows:

  - inventory: `inventory.yml`
  - playbook: `cluster.yml`

## Method

### Start cluster

You can start the cluster using either of the following commands:

  - Using the playbook: `ansible-playbook -i inventory.yml cluster.yml --become -e 'k3s_state=started'`
  - Using an ad-hoc command: `ansible -i inventory.yml -m service -a 'name=k3s state=started' --become all`

Below is example output, remember that Ansible is idempotent so re-running a
command may not necessarily change the state.

**Playbook method output**:

```text
PLAY RECAP *******************************************************************************************************
kube-0                     : ok=6    changed=0    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0
kube-1                     : ok=6    changed=0    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0
kube-2                     : ok=6    changed=0    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0
```

### Stop cluster

You can stop the cluster using either of the following commands:

  - Using the playbook: `ansible-playbook -i inventory.yml cluster.yml --become -e 'k3s_state=stopped'`
  - Using an ad-hoc command: `ansible -i inventory.yml -m service -a 'name=k3s state=stopped' --become all`

Below is example output, remember that Ansible is idempotent so re-running a
command may not necessarily change the state.

**Playbook method output**:

```text
PLAY RECAP *******************************************************************************************************
kube-0                     : ok=6    changed=1    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0
kube-1                     : ok=6    changed=1    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0
kube-2                     : ok=6    changed=1    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0
```

### Restart cluster

Just like the `service` module, you can also specify `restarted` as a state.
This will do `stop` followed by `start`.

  - Using the playbook: `ansible-playbook -i inventory.yml cluster.yml --become -e 'k3s_state=restarted'`
  - Using an ad-hoc command: `ansible -i inventory.yml -m service -a 'name=k3s state=restarted' --become all`

```text
PLAY RECAP *******************************************************************************************************
kube-0                     : ok=7    changed=1    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0
kube-1                     : ok=7    changed=1    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0
kube-2                     : ok=7    changed=1    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0
```

## Tips

You can limit the targets by adding the `-l` flag to your `ansible-playbook`
command, or simply target your ad-hoc commands. For example, in a 3 node
cluster (called `kube-0`, `kube-1` and `kube-2`) we can limit the restart to
`kube-1` and `kube-2` with the following:

  - Using the playbook: `ansible-playbook -i inventory.yml cluster.yml --become -e 'k3s_state=restarted' -l "kube-1,kube-2"`
  - Using an ad-hoc command: `ansible -i inventory.yml -m service -a 'name=k3s state=restarted' --become "kube-1,kube-2"`

```text
PLAY RECAP ********************************************************************************************************
kube-1                     : ok=7    changed=2    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0
kube-2                     : ok=7    changed=2    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0
```

## FAQ

  1. _Why might I use the `ansible-playbook` command over an ad-hoc command?_
     - The stop/start tasks will be aware of configuration. As the role
       develops, there might be some pre-tasks added to change how a cluster
       is stopped or started.
