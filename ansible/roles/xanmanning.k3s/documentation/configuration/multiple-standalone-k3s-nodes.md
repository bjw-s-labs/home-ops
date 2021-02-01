# Multiple standalone K3s nodes

This is an example of when you might want to configure multiple standalone
k3s nodes simultaneously. For this we will assume a hypothetical situation
where we are configuring 25 Raspberry Pis to deploy to our shop floors.

Each Rasperry Pi will be configured as a standalone IoT device hosting an
application that will push data to head office.

## Architecture

```text
+-------------+
|             |
|   Node-01   +-+
|             | |
+--+----------+ +-+
   |            | |
   +--+---------+ +-+
      |           | |
      +--+--------+ |
         |          |  Node-N
         +----------+

```

## Configuration

Below is our example inventory of 200 nodes (Truncated):

```yaml
---

k3s_workers:
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

     # ..... SNIP .....

     kube-199:
       ansible_user: ansible
       ansible_host: 10.10.9.201
       ansible_python_interpreter: /usr/bin/python3
     kube-200:
       ansible_user: ansible
       ansible_host: 10.10.9.202
       ansible_python_interpreter: /usr/bin/python3

```

In our `group_vars/` (or as `vars:` in our playbook), we will need to set the
`k3s_build_cluster` variable to `false`. This will stop the role from
attempting to cluster all 200 nodes, instead it will install k3s across each
node as as 200 standalone servers.

```yaml
---

k3s_build_cluster: false
```
