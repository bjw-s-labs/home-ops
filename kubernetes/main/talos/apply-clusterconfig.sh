#!/usr/bin/env bash

# Deploy the configuration to the nodes
talosctl apply-config -n 10.1.1.31 -f ./clusterconfig/main-delta.bjw-s.casa.yaml
talosctl apply-config -n 10.1.1.32 -f ./clusterconfig/main-enigma.bjw-s.casa.yaml
talosctl apply-config -n 10.1.1.33 -f ./clusterconfig/main-felix.bjw-s.casa.yaml
