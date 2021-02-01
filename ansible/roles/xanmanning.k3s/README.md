# Ansible Role: k3s (v2.x)

Ansible role for installing [K3S](https://k3s.io/) ("Lightweight
Kubernetes") as either a standalone server or cluster.

[![CI](https://github.com/PyratLabs/ansible-role-k3s/workflows/CI/badge.svg?event=push)](https://github.com/PyratLabs/ansible-role-k3s/actions?query=workflow%3ACI)

## Release notes

Please see [Releases](https://github.com/PyratLabs/ansible-role-k3s/releases)
and [CHANGELOG.md](CHANGELOG.md).

## Requirements

The host you're running Ansible from requires the following Python dependencies:

  - `ansbile >= 2.9.17` or `ansible-base >= 2.10.4`

You can install dependencies using the requirements.txt file in this repository:
`pip3 install -r requirements.txt`.

This role has been tested against the following Linux Distributions:

  - Amazon Linux 2
  - Archlinux
  - CentOS 8
  - CentOS 7
  - Debian 9
  - Debian 10
  - Fedora 29
  - Fedora 30
  - Fedora 31
  - Fedora 32
  - openSUSE Leap 15
  - Ubuntu 18.04 LTS
  - Ubuntu 20.04 LTS

:warning: The v2 releases of this role only supports `k3s >= v1.19`, for
`k3s < v1.19` please consider updating or use the v1.x releases of this role.

Before upgrading, see [CHANGELOG](CHANGELOG.md) for notifications of breaking
changes.

## Role Variables

Since K3s [v1.19.1+k3s1](https://github.com/k3s-io/k3s/releases/tag/v1.19.1%2Bk3s1)
you can now configure K3s using a
[configuration file](https://rancher.com/docs/k3s/latest/en/installation/install-options/#configuration-file)
rather than environment variables or command line arguments. The v2 release of
this role has moved to the configuration file method rather than populating a
systemd unit file with command-line arguments. There may be exceptions that are
defined in [Global/Cluster Variables](#globalcluster-variables), however you will
mostly be configuring k3s by configuration files using the `k3s_server` and
`k3s_agent` variables.

See "_Server (Control Plane) Configuration_" and "_Agent (Worker) Configuraion_"
below.

### Global/Cluster Variables

Below are variables that are set against all of the play hosts for environment
consistency. These are generally cluster-level configuration.

| Variable                         | Description                                                                     | Default Value                  |
|----------------------------------|---------------------------------------------------------------------------------|--------------------------------|
| `k3s_state`                      | State of k3s: installed, started, stopped, downloaded, uninstalled, validated.  | installed                      |
| `k3s_release_version`            | Use a specific version of k3s, eg. `v0.2.0`. Specify `false` for stable.        | `false`                        |
| `k3s_config_file`                | Location of the k3s configuration file.                                         | `/etc/rancher/k3s/config.yaml` |
| `k3s_build_cluster`              | When multiple play hosts are available, attempt to cluster. Read notes below.   | `true`                         |
| `k3s_control_node_address`       | Use a specific control node address. IP or FQDN.                                | NULL                           |
| `k3s_github_url`                 | Set the GitHub URL to install k3s from.                                         | https://github.com/k3s-io/k3s  |
| `k3s_install_dir`                | Installation directory for k3s.                                                 | `/usr/local/bin`               |
| `k3s_install_hard_links`         | Install using hard links rather than symbolic links.                            | `false`                        |
| `k3s_start_on_boot`              | Start k3s on boot.                                                              | `true`                         |
| `k3s_server_manifests_templates` | A list of Auto-Deploying Manifests Templates.                                   | []                             |
| `k3s_use_experimental`           | Allow the use of experimental features in k3s.                                  | `false`                        |
| `k3s_use_unsupported_config`     | Allow the use of unsupported configurations in k3s.                             | `false`                        |
| `k3s_etcd_datastore`             | Enable etcd embedded datastore (read notes below).                              | `false`                        |
| `k3s_debug`                      | Enable debug logging on the k3s service.                                        | `false`                        |

### Group/Host Variables

Below are variables that are set against individual or groups of play hosts.
Typically you'd set these at group level for the control plane or worker nodes.

| Variable           | Description                                                       | Default Value                                     |
|--------------------|-------------------------------------------------------------------|---------------------------------------------------|
| `k3s_control_node` | Specify if a host (or host group) are part of the control plane.  | `false` (role will automatically delegate a node) |
| `k3s_server`       | Server (control plane) configuration, see notes below.            | `{}`                                              |
| `k3s_agent`        | Agent (worker) configuration, see notes below.                    | `{}`                                              |

#### Server (Control Plane) Configuration

The control plane is configured with the `k3s_server` dict variable. Please
refer to the below documentation for configuration options:

https://rancher.com/docs/k3s/latest/en/installation/install-options/server-config/

The `k3s_server` dictionary variable will contain flags from the above
(removing the `--` prefix). Below is an example:

```yaml
k3s_server:
  datastore-endpoint: postgres://postgres:verybadpass@database:5432/postgres?sslmode=disable
  docker: true
  cluster-cidr: 172.20.0.0/16
  flannel-backend: 'none'  # This needs to be in quotes
  disable:
    - traefik
    - coredns
```

Alternatively, you can create a .yaml file and read it in to the `k3s_server`
variable as per the below example:

```yaml
k3s_server: "{{ lookup('file', 'path/to/k3s_server.yml') | from_yaml }}"
```

Check out the [Documentation](documentation/README.md) for example
configuration.

#### Agent (Worker) Configuration

Workers are configured with the `k3s_agent` dict variable. Please refer to the
below documentation for configuration options:

https://rancher.com/docs/k3s/latest/en/installation/install-options/agent-config

The `k3s_agent` dictionary variable will contain flags from the above
(removing the `--` prefix). Below is an example:

```yaml
k3s_agent:
  with-node-id: true
  node-label:
    - "foo=bar"
    - "hello=world"
```

Alternatively, you can create a .yaml file and read it in to the `k3s_agent`
variable as per the below example:

```yaml
k3s_agent: "{{ lookup('file', 'path/to/k3s_agent.yml') | from_yaml }}"
```

Check out the [Documentation](documentation/README.md) for example
configuration.

### Ansible Controller Configuration Variables

The below variables are used to change the way the role executes in Ansible,
particularly with regards to privilege escalation.

| Variable                            | Description                                                         | Default Value |
|-------------------------------------|---------------------------------------------------------------------|---------------|
| `k3s_skip_validation`               | Skip all tasks that validate configuration.                         | `false`       |
| `k3s_skip_env_checks`               | Skill all tasks that check environment configuration.               | `false`       |
| `k3s_become_for_all`                | Escalate user privileges for all tasks. Overrides all of the below. | `false`       |
| `k3s_become_for_systemd`            | Escalate user privileges for systemd tasks.                         | NULL          |
| `k3s_become_for_install_dir`        | Escalate user privileges for creating installation directories.     | NULL          |
| `k3s_become_for_directory_creation` | Escalate user privileges for creating application directories.      | NULL          |
| `k3s_become_for_usr_local_bin`      | Escalate user privileges for writing to `/usr/local/bin`.           | NULL          |
| `k3s_become_for_package_install`    | Escalate user privileges for installing k3s.                        | NULL          |
| `k3s_become_for_kubectl`            | Escalate user privileges for running `kubectl`.                     | NULL          |
| `k3s_become_for_uninstall`          | Escalate user privileges for uninstalling k3s.                      | NULL          |

#### Important note about `k3s_release_version`

If you do not set a `k3s_release_version` the latest version from the stable
channel of k3s will be installed. If you are developing against a specific
version of k3s you must ensure this is set in your Ansible configuration, eg:

```yaml
k3s_release_version: v1.19.3+k3s1
```

It is also possible to install specific K3s "Channels", below are some
examples for `k3s_release_version`:

```yaml
k3s_release_version: false             # defaults to 'stable' channel
k3s_release_version: stable            # latest 'stable' release
k3s_release_version: testing           # latest 'testing' release
k3s_release_version: v1.19             # latest 'v1.19' release
k3s_release_version: v1.19.3+k3s3      # specific release

# Specific commit
# CAUTION - only used for testing - must be 40 characters
k3s_release_version: 48ed47c4a3e420fa71c18b2ec97f13dc0659778b
```

#### Important note about `k3s_install_hard_links`

If you are using the [system-upgrade-controller](https://github.com/rancher/system-upgrade-controller)
you will need to use hard links rather than symbolic links as the controller
will not be able to follow symbolic links. This option has been added however
is not enabled by default to avoid breaking existing installations.

To enable the use of hard links, ensure `k3s_install_hard_links` is set
to `true`.

```yaml
k3s_install_hard_links: true
```

The result of this can be seen by running the following in `k3s_install_dir`:

`ls -larthi | grep -E 'k3s|ctr|ctl' | grep -vE ".sh$" | sort`

Symbolic Links:

```text
[root@node1 bin]# ls -larthi | grep -E 'k3s|ctr|ctl' | grep -vE ".sh$" | sort
3277823 -rwxr-xr-x 1 root root  52M Jul 25 12:50 k3s-v1.18.4+k3s1
3279565 lrwxrwxrwx 1 root root   31 Jul 25 12:52 k3s -> /usr/local/bin/k3s-v1.18.6+k3s1
3279644 -rwxr-xr-x 1 root root  51M Jul 25 12:52 k3s-v1.18.6+k3s1
3280079 lrwxrwxrwx 1 root root   31 Jul 25 12:52 ctr -> /usr/local/bin/k3s-v1.18.6+k3s1
3280080 lrwxrwxrwx 1 root root   31 Jul 25 12:52 crictl -> /usr/local/bin/k3s-v1.18.6+k3s1
3280081 lrwxrwxrwx 1 root root   31 Jul 25 12:52 kubectl -> /usr/local/bin/k3s-v1.18.6+k3s1
```

Hard Links:

```text
[root@node1 bin]# ls -larthi | grep -E 'k3s|ctr|ctl' | grep -vE ".sh$" | sort
3277823 -rwxr-xr-x 1 root root  52M Jul 25 12:50 k3s-v1.18.4+k3s1
3279644 -rwxr-xr-x 5 root root  51M Jul 25 12:52 crictl
3279644 -rwxr-xr-x 5 root root  51M Jul 25 12:52 ctr
3279644 -rwxr-xr-x 5 root root  51M Jul 25 12:52 k3s
3279644 -rwxr-xr-x 5 root root  51M Jul 25 12:52 k3s-v1.18.6+k3s1
3279644 -rwxr-xr-x 5 root root  51M Jul 25 12:52 kubectl
```

#### Important note about `k3s_build_cluster`

If you set `k3s_build_cluster` to `false`, this role will install each play
host as a standalone node. An example of when you might use this would be
when building a large number of standalone IoT devices running K3s. Below is a
hypothetical situation where we are to deploy 25 Raspberry Pi devices, each a
standalone system and not a cluster of 25 nodes. To do this we'd use a playbook
similar to the below:

```yaml
- hosts: k3s_nodes  # eg. 25 RPi's defined in our inventory.
  vars:
    k3s_build_cluster: false
  roles:
     - xanmanning.k3s
```

#### Important note about `k3s_control_node` and High Availability (HA)

By default only one host will be defined as a control node by Ansible, If you
do not set a host as a control node, this role will automatically delegate
the first play host as a control node. This is not suitable for use within
a Production workload.

If multiple hosts have `k3s_control_node` set to `true`, you must also set
`datastore-endpoint` in `k3s_server` as the connection string to a MySQL or
PostgreSQL database, or external Etcd cluster else the play will fail.

If using TLS, the CA, Certificate and Key need to already be available on
the play hosts.

See: [High Availability with an External DB](https://rancher.com/docs/k3s/latest/en/installation/ha/)

It is also possible, though not supported, to run a single K3s control node
with a `datastore-endpoint` defined. As this is not a typically supported
configuration you will need to set `k3s_use_unsupported_config` to `true`.

Since K3s v1.19.1 it is possible to use an embedded Etcd as the backend
database, and this is done by setting `k3s_etcd_datastore` to `true`.
The best practice for Etcd is to define at least 3 members to ensure quorum is
established. In addition to this, an odd number of members is recommended to
ensure a majority in the event of a network partition. If you want to use 2
members or an even number of members, please set `k3s_use_unsupported_config`
to `true`.

## Dependencies

No dependencies on other roles.

## Example Playbooks

Example playbook, single control node running `testing` channel k3s:

```yaml
- hosts: k3s_nodes
  roles:
     - { role: xanmanning.k3s, k3s_release_version: testing }
```

Example playbook, Highly Available with PostgreSQL database running the latest
stable release:

```yaml
- hosts: k3s_nodes
  vars:
    k3s_control_node_address: loadbalancer  # Typically a load balancer.
    k3s_server:
      datastore-endpoint: "postgres://postgres:verybadpass@database:5432/postgres?sslmode=disable"
  pre_tasks:
    - name: Set each node to be a control node
      ansible.builtin.set_fact:
        k3s_control_node: true
      when: inventory_hostname in ['node2', 'node3']
  roles:
    - role: xanmanning.k3s
```

## License

[BSD 3-clause](LICENSE.txt)

## Contributors

Contributions from the community are very welcome, but please read the
[contribution guidelines](CONTRIBUTING.md) before doing so, this will help
make things as streamlined as possible.

Also, please check out the awesome
[list of contributors](https://github.com/PyratLabs/ansible-role-k3s/graphs/contributors).

## Author Information

[Xan Manning](https://xan.manning.io/)
