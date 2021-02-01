# Quickstart: K3s single node

This is the quickstart guide to creating your own single-node k3s "cluster".

:hand: This example requires your Ansible user to be able to connect to the
server over SSH using key-based authentication. The user is also has an entry
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
  |_ single_node.yml
```

## Inventory

Here's a YAML based example inventory for our server called `inventory.yml`:

```yaml
---

k3s_cluster:
  hosts:
    kube-0:
      ansible_user: ansible
      ansible_host: 10.10.9.2
      ansible_python_interpreter: /usr/bin/python3

```

We can test this works with `ansible -i inventory.yml -m ping all`, expected
result:

```text
kube-0 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

## Playbook

Here is our playbook for a single node k3s cluster (`single_node.yml`):

```yaml
---

- name: Build a single node k3s cluster
  hosts: kube-0
  vars:
    k3s_become_for_all: true
  roles:
    - xanmanning.k3s
```

## Execution

To execute the playbook against our inventory file, we will run the following
command:

`ansible-playbook -i inventory.yml single_node.yml`

The output we can expect is similar to the below, with no failed or unreachable
nodes:

```text
PLAY RECAP *******************************************************************************************************
kube-0                     : ok=39   changed=8    unreachable=0    failed=0    skipped=39   rescued=0    ignored=0
```

## Testing

After logging into the server, we can test that k3s is running and that it is
ready to execute our Kubernetes workloads by running the following:

  - `sudo kubectl get nodes`
  - `sudo kubectl get pods -o wide --all-namespaces`

:hand: Note we are using `sudo` because we need to be root to access the
kube config for this node. This behavior can be changed with specifying
`write-kubeconfig-mode: 0644` in `k3s_server`.

**Get Nodes**:

```text
ansible@kube-0:~$ sudo kubectl get nodes
NAME     STATUS   ROLES    AGE     VERSION
kube-0   Ready    master   5m27s   v1.19.4+k3s
ansible@kube-0:~$
```

**Get Pods**:

```text
ansible@kube-0:~$ sudo kubectl get pods --all-namespaces -o wide
NAMESPACE     NAME                                     READY   STATUS      RESTARTS   AGE     IP          NODE     NOMINATED NODE   READINESS GATES
kube-system   metrics-server-7b4f8b595-k692h           1/1     Running     0          9m38s   10.42.0.2   kube-0   <none>           <none>
kube-system   local-path-provisioner-7ff9579c6-5lgzb   1/1     Running     0          9m38s   10.42.0.3   kube-0   <none>           <none>
kube-system   coredns-66c464876b-xg42q                 1/1     Running     0          9m38s   10.42.0.5   kube-0   <none>           <none>
kube-system   helm-install-traefik-tdpcs               0/1     Completed   0          9m38s   10.42.0.4   kube-0   <none>           <none>
kube-system   svclb-traefik-hk248                      2/2     Running     0          9m4s    10.42.0.7   kube-0   <none>           <none>
kube-system   traefik-5dd496474-bf4kv                  1/1     Running     0          9m4s    10.42.0.6   kube-0   <none>           <none>
```
