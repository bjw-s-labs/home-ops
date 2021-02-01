# ansible-role-k3s

This document describes a number of ways of consuming this Ansible role for use
in your own k3s deployments. It will not be able to cover every use case
scenario but will provide some common example configurations.

## Requirements

Before you start you will need an Ansible controller. This can either be your
workstation, or a dedicated system that you have access to. The instructions
in this documentation assume you are using `ansible` CLI, there are no
instructions available for Ansible Tower at this time.

Follow the below guide to get Ansible installed.

https://docs.ansible.com/ansible/latest/installation_guide/index.html

## Quickstart

Below are quickstart examples for a single node k3s server, a k3s cluster
with a single control node and HA k3s cluster. These represent the bare
minimum configuration.

  - [Single node k3s](quickstart-single-node.md)
  - [Simple k3s cluster](quickstart-cluster.md)
  - [HA k3s cluster using embedded etcd](quickstart-ha-cluster.md)

## Example configurations and operations

### Configuration

  - [Setting up 2-node HA control plane with external datastore](configuration/2-node-ha-ext-datastore.md)
  - [Provision multiple standalone k3s nodes](configuration/multiple-standalone-k3s-nodes.md)

### Operations

  - [Stop/Start a cluster](operations/stop-start-cluster.md)
  - [Updating k3s](operations/updating-k3s.md)
  - [Extending a cluster](operations/extending-a-cluster.md)
  - [Shrinking a cluster](operations/shrinking-a-cluster.md)
