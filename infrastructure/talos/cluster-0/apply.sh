#!/usr/bin/env bash

# Deploy the configuration to the nodes
talosctl apply-config -n 10.1.1.31 -f ./clusterconfig/cluster-0-delta.bjw-s.tech.yaml
talosctl apply-config -n 10.1.1.32 -f ./clusterconfig/cluster-0-enigma.bjw-s.tech.yaml
talosctl apply-config -n 10.1.1.33 -f ./clusterconfig/cluster-0-felix.bjw-s.tech.yaml
