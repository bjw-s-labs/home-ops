# Quickstart: K3s cluster with a single control node

This is the quickstart guide to creating your own k3s cluster with one control
plane node. This control plane node will also be a worker.

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
  |_ cluster.yml
```

## Inventory

Here's a YAML based example inventory for our servers called `inventory.yml`:

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

Here is our playbook for the k3s cluster (`cluster.yml`):

```yaml
---

- name: Build a cluster with a single control node
  hosts: k3s_cluster
  vars:
    k3s_become_for_all: true
  roles:
    - xanmanning.k3s
```

## Execution

To execute the playbook against our inventory file, we will run the following
command:

`ansible-playbook -i inventory.yml cluster.yml`

The output we can expect is similar to the below, with no failed or unreachable
nodes. The default behavior of this role is to delegate the first play host as
the control node, so kube-0 will have more changed tasks than others:

```text
PLAY RECAP *******************************************************************************************************
kube-0                     : ok=56   changed=11   unreachable=0    failed=0    skipped=28   rescued=0    ignored=0
kube-1                     : ok=43   changed=10   unreachable=0    failed=0    skipped=32   rescued=0    ignored=0
kube-2                     : ok=43   changed=10   unreachable=0    failed=0    skipped=32   rescued=0    ignored=0
```

## Testing

After logging into kube-0, we can test that k3s is running across the cluster,
that all nodes are ready and that everything is ready to execute our Kubernetes
workloads by running the following:

  - `sudo kubectl get nodes -o wide`
  - `sudo kubectl get pods -o wide --all-namespaces`

:hand: Note we are using `sudo` because we need to be root to access the
kube config for this node. This behavior can be changed with specifying
`write-kubeconfig-mode: 0644` in `k3s_server`.

**Get Nodes**:

```text
ansible@kube-0:~$ sudo kubectl get nodes -o wide
NAME     STATUS   ROLES    AGE   VERSION        INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME
kube-0   Ready    master   34s   v1.19.4+k3s1   10.0.2.15     <none>        Ubuntu 20.04.1 LTS   5.4.0-56-generic   containerd://1.4.1-k3s1
kube-2   Ready    <none>   14s   v1.19.4+k3s1   10.0.2.17     <none>        Ubuntu 20.04.1 LTS   5.4.0-56-generic   containerd://1.4.1-k3s1
kube-1   Ready    <none>   14s   v1.19.4+k3s1   10.0.2.16     <none>        Ubuntu 20.04.1 LTS   5.4.0-56-generic   containerd://1.4.1-k3s1
ansible@kube-0:~$
```

**Get Pods**:

```text
ansible@kube-0:~$ sudo kubectl get pods -o wide --all-namespaces
NAMESPACE     NAME                                     READY   STATUS      RESTARTS   AGE   IP          NODE     NOMINATED NODE   READINESS GATES
kube-system   local-path-provisioner-7ff9579c6-72j8x   1/1     Running     0          55s   10.42.2.2   kube-1   <none>           <none>
kube-system   metrics-server-7b4f8b595-lkspj           1/1     Running     0          55s   10.42.1.2   kube-2   <none>           <none>
kube-system   helm-install-traefik-b6vnt               0/1     Completed   0          55s   10.42.0.3   kube-0   <none>           <none>
kube-system   coredns-66c464876b-llsh7                 1/1     Running     0          55s   10.42.0.2   kube-0   <none>           <none>
kube-system   svclb-traefik-jrqg7                      2/2     Running     0          27s   10.42.1.3   kube-2   <none>           <none>
kube-system   svclb-traefik-gh65q                      2/2     Running     0          27s   10.42.0.4   kube-0   <none>           <none>
kube-system   svclb-traefik-5z7zp                      2/2     Running     0          27s   10.42.2.3   kube-1   <none>           <none>
kube-system   traefik-5dd496474-l2k74                  1/1     Running     0          27s   10.42.1.4   kube-2   <none>           <none>
```
