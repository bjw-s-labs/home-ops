# 2 Node HA Control Plane with external database

For this configuration we are deploying a highly available control plane
composed of two control nodes. This can be achieved with embedded etcd, however
etcd ideally has an odd number of nodes.

The example below will use an external PostgreSQL datastore to store the
cluster state information.

Main guide: https://rancher.com/docs/k3s/latest/en/installation/ha/

## Architecture

```text
                     +---------------+
                     | Load Balancer |
                     +-------+-------+
                             |
                             |
                             |
                             |
         +------------+      |      +------------+
         |            |      |      |            |
+--------+ control-01 +<-----+----->+ control-02 |
|        |            |             |            |
|        +-----+------+             +------+-----+
|              |                           |
|              +-------------+-------------+
|              |             |             |
|       +------v----+  +-----v-----+  +----v------+
|       |           |  |           |  |           |
|       | worker-01 |  | worker-02 |  | worker-03 |
|       |           |  |           |  |           |
|       +-----------+  +-----------+  +-----------+
|
|                   +-------+  +-------+
|                   |       |  |       |
+-------------------> db-01 +--+ db-02 |
                    |       |  |       |
                    +-------+  +-------+
```

### Required Components

  - Load balancer
  - 2 control plane nodes
  - 1 or more worker nodes
  - PostgreSQL Database (replicated, or Linux HA Cluster).

## Configuration

For your control nodes, you will need to instruct the control plane of the
PostgreSQL datastore endpoint and set `k3s_control_node_address` to be the
hostname or IP of your load balancer.

Below is the example for PostgreSQL, it is possible to use MySQL or an Etcd
cluster as well. Consult the below guide for using alternative datastore
endpoints.

https://rancher.com/docs/k3s/latest/en/installation/datastore/#datastore-endpoint-format-and-functionality

```yaml
---

k3s_server:
  datastore-endpoint: postgres://postgres:verybadpass@database:5432/postgres?sslmode=disable
```

Your worker nodes need to know how to connect to the control plane, this is
defined by setting `k3s_control_node_address` to the hostname or IP address of
the load balancer.

```yaml
---

k3s_control_node_address: control.examplek3s.com
```
