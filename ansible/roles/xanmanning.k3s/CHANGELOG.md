# Change Log

<!--
## DATE, vx.x.x

### Notable changes

### Breaking changes

### Known issues

### Contributors

---
-->

## 2021-01-31, v2.5.3

### Notable changes

  - Bugfix, missing update to minimum ansible version var #91.

---

## 2021-01-30, v2.5.2

### Notable changes

  - Bugfix, missing `k3s_start_on_boot` to control `systemd.enabled` added.

---

## 2021-01-30, v2.5.1

### Notable changes

  - Added uninstall task to remove hard-linked files #88
  - Fixed missing become for `systemd` operations tasks. #89
  - Added `k3s_start_on_boot` to control `systemd.enabled`.

---

## 2021-01-24, v2.5.0

### Notable changes

  - Added support for Ansible >= 2.9.17 #83

---

## 2021-01-23, v2.4.3

### Notable changes

  - Bufgix: Installation hangs on "Check that all nodes to be ready" #84

---

## 2021-01-10, v2.4.2

### Notable changes

  - Bufgix: Docker check still failing on "false"

---

## 2021-01-02, v2.4.1

### Notable changes

  - Fixed issue with armv6l (Raspberry Pi Zero W)
  - Added path for private repositories config to directory creation list.

---

## 2020-12-21, v2.4.0

### Notable changes

  - `k3s_config_dir` derived from `k3s_config_file`, reused throughout the role
    to allow for easy removal of "Rancher" references #73.
  - `k3s_token_location` has moved to be in `k3s_config_dir`.
  - Tasks for creating directories now looped to caputure configuration from
    `k3s_server` and `k3s_agent` and ensure directories exist before k3s
    starts, see #75.
  - Server token collected directly from token file, not symlinked file
    (node-token).
  - `k3s_runtime_config` defined in `vars/` for validation and overwritten in
    tasks for control plane and workers.
  - Removed unused references to GitHub API.
  - `set_fact` and `command` tasks now use FQCN.
  - Check of `ansible_version` in environment check.
  - Introduction of target environment checks for #72.
  - Fixed bug with non-default listening port not being passed to workers.
  - Added ability to put documentation links into validation checks #76.
  - Removed the requirement for `jmespath` on the Ansible controller.
  - Fixed bug with issue data collection tasks.

### Breaking changes

  - Ansible minimum version is hard set to v2.10.4
  - `k3s_token_location` has moved to be in `k3s_config_dir` so re-running the
    role will create a duplicate file here.

---

## 2020-12-19, v2.3.0

### Notable changes

  - Updated k3s uninstall scripts #74
  - Started moving Rancher references to `vars/` as per #73

---

## 2020-12-19, v2.2.2

### Notable changes

  - Fixed typos in documentation.
  - Molecule testing pinned to v3.1 due to tests failing.

---

## 2020-12-16, v2.2.1

### Notable changes

  - Re-working documentation
  - Updated GitHub link, org changed from Rancher to k3s-io.
  - Replace deprecated `play_hosts` variable.

### Breaking changes

  - Moving git branch from `master` to `main`.

---

## 2020-12-12, v2.2.0

### Notable changes

  - Use of FQCNs enforced, minimum Ansible version now v2.10
  - `k3s_etcd_datastore` no longer experimental after K3s version v1.19.5+k3s1
  - Docker marked as deprecated for K3s > v1.20.0+k3s1

### Breaking changes

  - Use of FQCNs enforced, minimum Ansible version now v2.10
  - Use of Docker requires `k3s_use_unsupported_config` to be `true` after
    v1.20.0+k3s1

---

## 2020-12-05, v2.1.1

### Notable changes

  - Fixed link to documentation.

---

## 2020-12-05, v2.1.0

### Notable changes

  - Deprecated configuration check built into validation steps.
  - Removed duplicated tasks for single node cluster.
  - Added documentation providing quickstart examples and common operations.
  - Fixed data-dir configuration.
  - Some tweaks to rootless.
  - Fix draining and removing of nodes.

### Breaking changes

  - `k3s_token_location` now points to a file location, not a directory.
  - `k3s_systemd_unit_directory` renamed to `k3s_systemd_unit_dir`
  - Removed `k3s_node_data_dir` as this is now configured with `data-dir` in
    `k3s_server` and/or `k3s_agent`.

### Known issues

  - Rootless is still broken, this is still not supported as a method for
    running k3s using this role.

---

## 2020-11-30, v2.0.2

### Notable changes

  - Updated issue template and information collection tasks.

---

## 2020-11-30, v2.0.1

### Notable changes

  - Fixed a number of typos in the README.md
  - Updated the meta/main.yml to put quotes around minimum Ansible version.

---

## 2020-11-29, v2.0.0

### Notable changes

  - #64 - Initial release of v2.0.0 of
    [ansible-role-k3s](https://github.com/PyratLabs/ansible-role-k3s).
  - Minimum supported k3s version now: v1.19.1+k3s1
  - Minimum supported Ansible version now: v2.10.0
  - #62 - Remove all references to the word "master".
  - #53 - Move to file-based configuration.
  - Refactored to avoid duplication in code and make contribution easier.
  - Validation checks moved to using variables defined in `vars/`

### Breaking changes

#### File based configuration

Issue #53

With the release of v1.19.1+k3s1, this role has moved to file-based
configuration of k3s. This requires manuall translation of v1 configuration
variables into configuration file format.

Please see: https://rancher.com/docs/k3s/latest/en/installation/install-options/#configuration-file

#### Minimum supported k3s version

As this role now relies on file-based configuration, the v2.x release of this
role will only support v1.19+ of k3s. If you are not in a position to update
k3s you will need to continue using the v1.x release of this role, which will
be supported until March 2021<!-- 1 year after k8s v1.18 release -->.

#### Minimum supported ansible version

This role now only supports Ansible v2.10+, this is because it has moved on to
using FQDNs, with the exception of `set_fact` tasks which have
[been broken](https://github.com/ansible/ansible/issues/72319) and the fixes
have [not yet been backported to v2.10](https://github.com/ansible/ansible/pull/71824).

The use of FQDNs allows for custom modules to be introduced to override task
behavior. If this role requires a custom ansible module to be introduced then
this can be added as a dependency and targeted specifically by using the
correct FQDN.
