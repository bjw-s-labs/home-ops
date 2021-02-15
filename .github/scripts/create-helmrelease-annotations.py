#!/usr/bin/env python3

import git
import pathlib
import yaml

GIT_REPO=git.Repo(pathlib.Path.cwd(), search_parent_directories=True)
REPO_ROOT=pathlib.Path(GIT_REPO.working_dir)
CLUSTER_ROOT=pathlib.Path(GIT_REPO.working_dir, 'cluster')
NAMESPACES_ROOT=pathlib.Path(CLUSTER_ROOT, "namespaces")

HELM_REPOS={}
HELM_REPO_FILES=pathlib.Path(CLUSTER_ROOT, 'base', 'system-flux', 'helm-chart-repositories').glob('*.yaml')
for helm_repo in HELM_REPO_FILES:
    helm_repo_yaml = yaml.load(helm_repo.read_bytes(), Loader=yaml.FullLoader)

    if not helm_repo_yaml['apiVersion'] == 'source.toolkit.fluxcd.io/v1beta1' or \
       not helm_repo_yaml['kind'] == 'HelmRepository':
        break

    HELM_REPOS[helm_repo_yaml['metadata']['name']]=helm_repo_yaml['spec']['url']

HELM_RELEASE_FILES=NAMESPACES_ROOT.rglob('helmrelease.yaml')
for helm_release in HELM_RELEASE_FILES:
    helm_release_yaml = yaml.load(helm_release.read_bytes(), Loader=yaml.FullLoader)

    if helm_release_yaml['apiVersion'] == 'helm.toolkit.fluxcd.io/v2beta1' and \
       helm_release_yaml['kind'] == 'HelmRelease' and \
       helm_release_yaml['spec']['chart']['spec']['sourceRef']['kind'] == 'HelmRepository' and \
       helm_release_yaml['spec']['chart']['spec']['sourceRef']['name'] in HELM_REPOS:

        helm_release_name = helm_release_yaml['metadata']['name']
        helm_release_namespace = helm_release_yaml['metadata']['namespace']
        helm_repo_name=helm_release_yaml['spec']['chart']['spec']['sourceRef']['name']
        helm_repo_url=HELM_REPOS[helm_release_yaml['spec']['chart']['spec']['sourceRef']['name']]

        print('Annotating HelmRelease {namespace}/{helmrelease} with registry {registry} for renovatebot...'.format(namespace=helm_release_namespace, helmrelease=helm_release_name, registry=helm_repo_name))
        with open(helm_release, mode='r') as fid:
            lines = fid.read().splitlines()

        with open(helm_release, mode='w') as fid:
            for line in lines:
                if '# renovate: registryUrl=' in line:
                    continue

                if 'chart: ' in line:
                    fid.write('      # renovate: registryUrl={}\n'.format(helm_repo_url))

                fid.write('{}\n'.format(line))
