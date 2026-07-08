---
name: add-app
description: Use when deploying a new application to the cluster — scaffolding a Flux Kustomization plus app-template HelmRelease under kubernetes/apps/ (new app, new service, "add X to the cluster")
---

# Add a New Application

Scaffolds `kubernetes/apps/<namespace>/<app>/` with a Flux Kustomization (`ks.yaml`) and an app-template HelmRelease. Every value below comes from current repo conventions — when in doubt, mirror a recent real app instead of inventing structure:

| Reference app | Shows |
|---|---|
| `kubernetes/apps/network/echo-server` | Minimal stateless app + route |
| `kubernetes/apps/selfhosted/wotcher` | Secrets, config file via configMapGenerator, kopiur-backed persistence |
| `kubernetes/apps/selfhosted/searxng` | Custom probes, CiliumNetworkPolicy, dragonfly dependency |

## Step 1: Gather details

Ask the user (AskUserQuestion) for anything not already given:

1. **App name** and **namespace** (existing dirs: `ls kubernetes/apps/`)
2. **Image** repository + tag (upstream's current release)
3. **Port** the app listens on, and whether it gets a **route** (hostname); internal (`envoy-internal`, default) or public (`envoy-external`)
4. **Persistence** — does the app store state? (→ kopiur backup component)
5. **Secrets** — env vars from 1Password? (→ ExternalSecret). Get the 1Password item name AND its exact field names — never guess field names
6. **Config files** — mounted config? (→ configMapGenerator + `resources/`)
7. **Dependencies** — other Flux Kustomizations this app needs

## Step 2: Create the files

Layout:

```
kubernetes/apps/<namespace>/<app>/
├── ks.yaml
└── app/
    ├── kustomization.yaml
    ├── ocirepository.yaml
    ├── helmrelease.yaml
    ├── externalsecret.yaml      # only if secrets
    └── resources/               # only if config files
```

### ks.yaml

```yaml
---
# yaml-language-server: $schema=https://k8s-schemas.home-operations.com/kustomize.toolkit.fluxcd.io/kustomization_v1.json
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: <app>
spec:
  interval: 1h
  path: "./kubernetes/apps/<namespace>/<app>/app"
  prune: true
  sourceRef:
    kind: GitRepository
    name: flux-system
    namespace: flux-system
  targetNamespace: <namespace>
```

**`wait`:** omit it for a normal leaf app — it defaults to `false`, and explicit `wait: false` is redundant boilerplate we no longer keep. Only add `wait: true` when *another* Kustomization will `dependsOn` this one AND this Kustomization defines no `healthChecks`/`healthCheckExprs` — that is what gives the dependent a real readiness gate. If this Kustomization does define `healthChecks`, leave `wait` unset (setting `wait: true` would make Flux ignore those checks). Depending on another app (e.g. `kopiur` for persistence) does not by itself call for `wait`.

Do not add `commonMetadata` or `timeout` — both were dropped as boilerplate; the app-template chart sets `app.kubernetes.io/*` labels on the workloads, and `timeout` falls back to the Flux default.

**If the app has persistence**, add these to `spec` (components use `${APP}` and `${KOPIUR_*}` substitutions — see `kubernetes/components/kopiur/backup/` for all knobs and their defaults):

```yaml
  components:
    - ../../../../components/kopiur/backup
  dependsOn:
    - name: kopiur
      namespace: system
  postBuild:
    substitute:
      APP: <app>
      # Optional overrides, only when defaults don't fit:
      # KOPIUR_CLAIM: <app>-data      # PVC name (default: <app>)
      # KOPIUR_CAPACITY: 15Gi         # default: 5Gi
      # KOPIUR_MOVER_UID: "1000"      # default: 2000
      # KOPIUR_MOVER_GID: "1000"      # default: 2000
```

Add user-specified dependencies to `dependsOn`. Include `postBuild.substitute.APP` whenever any component is used; omit `components`/`postBuild` entirely otherwise.

### app/kustomization.yaml

```yaml
---
# yaml-language-server: $schema=https://json.schemastore.org/kustomization
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ./externalsecret.yaml   # only if secrets
  - ./ocirepository.yaml
  - ./helmrelease.yaml
```

**If the app mounts config files**, put them in `resources/` and append:

```yaml
configMapGenerator:
  - name: <app>-configmap
    files:
      - config.yaml=./resources/config.yaml
generatorOptions:
  disableNameSuffixHash: true
  annotations:
    kustomize.toolkit.fluxcd.io/substitute: disabled
```

### app/ocirepository.yaml

```yaml
---
# yaml-language-server: $schema=https://k8s-schemas.home-operations.com/source.toolkit.fluxcd.io/ocirepository_v1.json
apiVersion: source.toolkit.fluxcd.io/v1
kind: OCIRepository
metadata:
  name: <app>
spec:
  interval: 15m
  layerSelector:
    mediaType: application/vnd.cncf.helm.chart.content.v1.tar+gzip
    operation: copy
  ref:
    tag: <version>
  url: oci://ghcr.io/bjw-s-labs/helm/app-template
```

**Never hardcode `<version>` from memory** — use the version the rest of the repo is on:

```bash
/usr/bin/grep -h "tag:" kubernetes/apps/*/*/app/ocirepository.yaml | sort | uniq -c | sort -rn | head -1
```

### app/helmrelease.yaml

```yaml
---
# yaml-language-server: $schema=https://raw.githubusercontent.com/bjw-s-labs/helm-charts/main/charts/other/app-template/schemas/helmrelease-helm-v2.schema.json
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: <app>
spec:
  chartRef:
    kind: OCIRepository
    name: <app>
  interval: 30m
  values:
    controllers:
      <app>:
        annotations:
          reloader.stakater.com/auto: "true"
        pod:
          securityContext:
            runAsGroup: 2000
            runAsNonRoot: true
            runAsUser: 2000
        containers:
          app:
            image:
              repository: <image-repo>
              tag: <image-tag>
            probes:
              liveness:
                enabled: true
              readiness:
                enabled: true
            resources:
              requests:
                cpu: 10m
              limits:
                memory: 256Mi
            securityContext:
              allowPrivilegeEscalation: false
              readOnlyRootFilesystem: true
              capabilities:
                drop:
                  - ALL
    service:
      app:
        ports:
          http:
            port: <port>
```

Adjust `runAsUser`/`runAsGroup` (and capabilities) to what the image requires; drop the pod `securityContext` only if the image genuinely can't run non-root. Plain image tags are fine — Renovate pins digests and manages updates.

**Optional value blocks** (top-level under `values`, alphabetical: `controllers`, `persistence`, `route`, `service`):

Route (web UI/API):

```yaml
    route:
      app:
        hostnames:
          - <app>.bjw-s.dev
        parentRefs:
          - name: envoy-internal    # envoy-external for public apps
            namespace: network
```

Persistence (pairs with the kopiur block in ks.yaml; also add `fsGroup: 2000` + `fsGroupChangePolicy: OnRootMismatch` to the pod securityContext):

```yaml
    persistence:
      data:
        existingClaim: <app>       # must match KOPIUR_CLAIM if overridden
        globalMounts:
          - path: /data
      tmpfs:                       # writable /tmp for readOnlyRootFilesystem
        type: emptyDir
        globalMounts:
          - path: /tmp
```

Config file mount (pairs with configMapGenerator):

```yaml
    persistence:
      config:
        type: configMap
        name: <app>-configmap
        globalMounts:
          - path: /config/config.yaml
            subPath: config.yaml
            readOnly: true
```

Secrets: add to the container:

```yaml
            envFrom:
              - secretRef:
                  name: <app>-secret
```

### app/externalsecret.yaml (only if secrets)

```yaml
---
# yaml-language-server: $schema=https://k8s-schemas.home-operations.com/external-secrets.io/externalsecret_v1.json
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: <app>
spec:
  refreshInterval: 12h
  secretStoreRef:
    kind: ClusterSecretStore
    name: onepassword-connect
  target:
    name: <app>-secret
    creationPolicy: Owner
    template:
      data:
        SOME_ENV_VAR: "{{ .<app>_field_name }}"
  dataFrom:
    - extract:
        key: <1password-item>
      rewrite:
        - regexp:
            source: "(.*)"
            target: "<app>_$1"
```

Convention: `metadata.name` is `<app>`, the generated Secret is `<app>-secret`, and `dataFrom.extract` + `rewrite` prefixes 1Password fields for use in `template.data` (see wotcher for a multi-item example). The `.<prefix>_<field>` references must use the item's real field names (from Step 1) — a wrong field name renders an empty value with no error. If the field names weren't provided and you can't ask, insert `<FIXME: 1password field name>` placeholders and call them out.

## Step 3: Register in the namespace kustomization

Add `./<app>/ks.yaml` to `kubernetes/apps/<namespace>/kustomization.yaml` `resources`, in alphabetical position among the app entries (`namespace.yaml` stays first; leave existing entries where they are).

**New namespace?** Create `kubernetes/apps/<namespace>/` with a `namespace.yaml` and `kustomization.yaml` copied from an existing namespace (e.g. `selfhosted`) — keep the `flux-alerts` and `kopiur/secret` components and the literal `name: _` in namespace.yaml (kustomize renames it) — and register the directory in `kubernetes/flux/cluster`'s apps kustomization if namespaces are listed there.

## Step 4: Verify

```bash
kustomize build kubernetes/apps/<namespace>/<app>/app   # must render; ${APP} vars staying literal is expected
yamllint --config-file .yamllint.yaml kubernetes/apps/<namespace>/<app>
```

Show the user the created files and get confirmation before committing. Commit style: `feat(<app>): Deploy`.

## Common mistakes

- **Copying a chart version or image tag from this skill or memory** — always read the current version from the repo (Step 2 command) and upstream.
- **Using volsync** — this repo migrated to kopiur; `components/volsync` no longer exists.
- **Forgetting `reloader.stakater.com/auto`** — without it, secret/config changes don't restart pods.
- **`readOnlyRootFilesystem: true` without a tmpfs** — apps that write to `/tmp` will crash; mount an emptyDir.
- **Skipping the sorting conventions** — HelmRelease values follow `.agents/instructions/sorting.instructions.md`.
- **Adding a CiliumNetworkPolicy by default** — only some apps lock down ingress; copy `searxng`'s if the user asks for one.
- **Adding `wait`, `commonMetadata`, or `timeout` to `ks.yaml`** — all three are boilerplate now. Leave `wait` unset unless another Kustomization depends on this one and it has no `healthChecks` (then, and only then, `wait: true`).
