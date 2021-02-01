# Quickstart: K3s cluster with a HA control plane using embedded etcd

This is the quickstart guide to creating your own 3 node k3s cluster with a
highly available control plane using the embedded etcd datastore.
The control plane will all be workers as well.

:hand: This example requires your Ansible user to be able to connect to the
servers over SSH using key-based authentication. The user is also has an entry
in a sudoers file that allows privilege escalation without requiring a
password.

To test this is the case, run the following check replacing `<ansible_user>`
and `<server_name>`. The expected output is `Works`

`ssh <ansible_user>@<server_name> 'sudo cat /etc/shadow >/dev/null && echo "Works"'`

For example:

```text
[ xmanning@dreadfort:~/git/kubernetes-playground ] (master) $ ssh ansible@kube-0 'sudo cat /etc/shadow >/dev/null && echo "Works"'
Works
[ xmanning@dreadfort:~/git/kubernetes-playground ] (master) $
```

## Directory structure

Our working directory will have the following files:

```text
kubernetes-playground/
  |_ inventory.yml
  |_ ha_cluster.yml
```

## Inventory

Here's a YAML based example inventory for our servers called `inventory.yml`:

```yaml
---

# We're adding k3s_control_node to each host, this can be done in host_vars/
# or group_vars/ as well - but for simplicity we are setting it here.
k3s_cluster:
  hosts:
    kube-0:
      ansible_user: ansible
      ansible_host: 10.10.9.2
      ansible_python_interpreter: /usr/bin/python3
      k3s_control_node: true
    kube-1:
      ansible_user: ansible
      ansible_host: 10.10.9.3
      ansible_python_interpreter: /usr/bin/python3
      k3s_control_node: true
    kube-2:
      ansible_user: ansible
      ansible_host: 10.10.9.4
      ansible_python_interpreter: /usr/bin/python3
      k3s_control_node: true

```

We can test this works with `ansible -i inventory.yml -m ping all`, expected
result:

```text
kube-0 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
kube-1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
kube-2 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}

```

## Playbook

Here is our playbook for the k3s cluster (`ha_cluster.yml`):

```yaml
---

- name: Build a cluster with HA control plane
  hosts: k3s_cluster
  vars:
    k3s_become_for_all: true
    k3s_etcd_datastore: true
    k3s_use_experimental: true  # Note this is required for k3s < v1.19.5+k3s1
  roles:
    - xanmanning.k3s
```

## Execution

To execute the playbook against our inventory file, we will run the following
command:

`ansible-playbook -i inventory.yml ha_cluster.yml`

The output we can expect is similar to the below, with no failed or unreachable
nodes. The default behavior of this role is to delegate the first play host as
the primary control node, so kube-0 will have more changed tasks than others:

```text
PLAY RECAP *******************************************************************************************************
kube-0                     : ok=53   changed=8    unreachable=0    failed=0    skipped=30   rescued=0    ignored=0
kube-1                     : ok=47   changed=10   unreachable=0    failed=0    skipped=28   rescued=0    ignored=0
kube-2                     : ok=47   changed=9    unreachable=0    failed=0    skipped=28   rescued=0    ignored=0
```

## Testing

After logging into any of the servers (it doesn't matter), we can test that k3s
is running across the cluster, that all nodes are ready and that everything is
ready to execute our Kubernetes workloads by running the following:

  - `sudo kubectl get nodes -o wide`
  - `sudo kubectl get pods -o wide --all-namespaces`

:hand: Note we are using `sudo` because we need to be root to access the
kube config for this node. This behavior can be changed with specifying
`write-kubeconfig-mode: 0644` in `k3s_server`.

**Get Nodes**:

```text
ansible@kube-0:~$ sudo kubectl get nodes -o wide
NAME     STATUS   ROLES         AGE     VERSION        INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME
kube-0   Ready    etcd,master   2m58s   v1.19.4+k3s1   10.10.9.2     10.10.9.2     Ubuntu 20.04.1 LTS   5.4.0-56-generic   containerd://1.4.1-k3s1
kube-1   Ready    etcd,master   2m22s   v1.19.4+k3s1   10.10.9.3     10.10.9.3     Ubuntu 20.04.1 LTS   5.4.0-56-generic   containerd://1.4.1-k3s1
kube-2   Ready    etcd,master   2m10s   v1.19.4+k3s1   10.10.9.4     10.10.9.4     Ubuntu 20.04.1 LTS   5.4.0-56-generic   containerd://1.4.1-k3s1
```

**Get Pods**:

```text
ansible@kube-0:~$ sudo kubectl get pods -o wide --all-namespaces
NAMESPACE     NAME                                     READY   STATUS      RESTARTS   AGE     IP          NODE     NOMINATED NODE   READINESS GATES
kube-system   coredns-66c464876b-rhgn6                 1/1     Running     0          3m38s   10.42.0.2   kube-0   <none>           <none>
kube-system   helm-install-traefik-vwglv               0/1     Completed   0          3m39s   10.42.0.3   kube-0   <none>           <none>
kube-system   local-path-provisioner-7ff9579c6-d5xpb   1/1     Running     0          3m38s   10.42.0.5   kube-0   <none>           <none>
kube-system   metrics-server-7b4f8b595-nhbt8           1/1     Running     0          3m38s   10.42.0.4   kube-0   <none>           <none>
kube-system   svclb-traefik-9lzcq                      2/2     Running     0          2m56s   10.42.1.2   kube-1   <none>           <none>
kube-system   svclb-traefik-vq487                      2/2     Running     0          2m45s   10.42.2.2   kube-2   <none>           <none>
kube-system   svclb-traefik-wkwkk                      2/2     Running     0          3m1s    10.42.0.7   kube-0   <none>           <none>
kube-system   traefik-5dd496474-lw6x8                  1/1     Running     0          3m1s    10.42.0.6   kube-0   <none>           <none>
```
