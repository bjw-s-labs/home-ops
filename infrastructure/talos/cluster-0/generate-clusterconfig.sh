#!/usr/bin/env bash

# Generate a new config using talhelper
talhelper genconfig --env-file talenv.sops.yaml --secret-file talsecret.sops.yaml --config-file talconfig.yaml
