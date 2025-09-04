#!/usr/bin/env -S just --justfile

set quiet := true
set shell := ['bash', '-euo', 'pipefail', '-c']

mod k8s-bootstrap "kubernetes/bootstrap"
mod k8s "kubernetes"
mod talos "kubernetes/talos"

[private]
default:
    just -l

[private]
log lvl msg *args:
  gum log -t rfc3339 -s -l "{{ lvl }}" "{{ msg }}" {{ args }}

[private]
template file *args:
  minijinja-cli "{{ file }}" {{ args }} | op inject
