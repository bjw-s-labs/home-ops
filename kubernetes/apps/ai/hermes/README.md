# Hermes Webapp preview

Hermes exposes two interfaces from the same persistent profile:

- Native Webapp: `https://hermes.bjw-s.dev` (gateway port 9120).
- Hermes Dashboard: `https://hermes-dash.bjw-s.dev` (port 9119).

The single application container runs the gateway and Dashboard under the image's
s6 supervisor. `gateway run` starts the gateway, which serves the Webapp;
`HERMES_DASHBOARD=true` enables the separate Dashboard process on port 9119.

Connect Hermes Desktop to `https://hermes.bjw-s.dev` and sign in through Kanidm.
This endpoint uses the gateway's live session authority. The standalone Dashboard
retains maintenance operations that require exclusive database access and can be
refused while the gateway owns the profile, even when both processes share a container.

## Image and authentication

The backend and Dashboard use upstream development revision
`7020ea3e96c3fdbc768c5296493e186df46f075b`, not a stable release. Its published
multi-architecture image includes the prebuilt Webapp and confidential OIDC
support. Both interfaces share the existing Kanidm confidential client and
generated Secret, using `/auth/callback` on their respective hostnames. Kanidm's
scope map restricts access to `hermes_admins`. Every admitted account has full
agent access.

## Configuration ownership

`app/resources/config.yaml` is a read-only managed overlay mounted at
`/etc/hermes/config.yaml` (Hermes' supported path). It pins Webapp and Dashboard
addresses, Kanidm OIDC, the LiteLLM provider and credential helper, the gateway
topology, secret redaction, and the local terminal backend. Managed values take
precedence over each profile's settings.

Profile configuration, `.env`, and `SOUL.md` live on the PVC. The deployment
does not seed or rewrite profile files at startup. Hermes' per-profile command
secret source reads the LiteLLM key from a read-only Kubernetes Secret mount and
supplies the SearXNG URL. The pod exposes the existing shared mise install and
shims through `PATH` and reuses the existing workspace on the PVC.

Hermes resolves secret sources and external skill directories from each profile's
raw `config.yaml`, bypassing the machine-level overlay. These settings must be
owned exclusively by the profile: declaring them in `/etc/hermes/config.yaml`
causes every Dashboard config save to strip them from the profile, even though
their runtime readers cannot inherit the managed values.

For each profile that needs LiteLLM credentials and the shared toolkit, merge the
following into `/opt/data/profiles/<name>/config.yaml` (or `/opt/data/config.yaml`
for the default profile). Preserve sibling settings such as `skills.disabled`,
other secret sources, and all unrelated preferences. This contains only a helper
declaration, never the resolved credential:

```yaml
secrets:
  command:
    enabled: true
    command: |
      set -eu
      printf 'LITELLM_API_KEY='
      /bin/cat /mnt/secrets/litellm/key
      printf '\nSEARXNG_URL=http://searxng.selfhosted.svc.cluster.local:8080\n'
    helper_timeout_seconds: 3
    override_existing: true

skills:
  external_dirs:
    - /opt/data/shared/skills
```

### Recovery from stripped profile settings

Deploy the overlay change removing `secrets.command` and `skills.external_dirs`
before restoring either profile. Verify those sections are absent from the live
`/etc/hermes/config.yaml`; otherwise the next Dashboard save will strip them again.

With an explicitly authorized live repair, back up the current profile files,
then merge only the settings above into `homelab-operator` and
`home-assistant-helper`. Do not restore whole historical configs: that would undo
recent Dashboard edits. Restart the gateway after restoration so it rebuilds
profile credential scopes and MCP connections.

Validate both profiles by saving an unrelated preference in the Dashboard and
confirming these settings remain in their files. After a gateway restart, verify
shared skills appear (subject to each profile's disabled list), LiteLLM requests
succeed, and MCP connections no longer report a missing `LITELLM_API_KEY`. Never
print the helper output when checking credential availability.

## Shared forge toolkit and workspace

The Forge Toolkit is already installed on the persistent PVC under
`/opt/data/shared/`. Pod restarts reuse the existing files; profiles load
`/opt/data/shared/skills` through their own `skills.external_dirs` setting as
described above. Configure this explicitly for each new profile that needs it.

Repository identifiers always use `HOST/OWNER/REPO`. The `forge-repos` skill
guides discovery; `forge-git repo path` resolves the canonical path and
`forge-git repo ensure` reuses a matching checkout or clones a missing one under
`/opt/data/workspace/repos/<host>/<owner>/<repo>`. Existing remotes are checked;
the helper does not reset or update an existing checkout.

`hermes-forgejo` remains the source of the read-only
`/mnt/secrets/forges/forgejo/git.bjw-s.dev` credential. `forge-auth` selects a
CLI by both provider and hostname, while Git's shared global config uses
`git-credential-forge` and disables synthesized identities. `forge-git` resolves
commit identity from the authenticated account API or an operator-supplied
`/opt/data/shared/forge-identities.json`. That optional file is deliberately
not created or populated by GitOps. Never put credentials in it or in GitOps.

To add another forge, create an ExternalSecret only after its credential exists,
mount the Secret read-only at
`/mnt/secrets/forges/<provider>` with its key named for the forge hostname, and
add the hostname/provider pair to the persistent host mapping. Add only the
required egress for that forge, preserving the existing Forgejo route. Review
the provider's documented CLI and API endpoints before enabling it. Do not put
tokens in the host mapping or CLI configuration. The existing mise tools and
Forge Toolkit files are operator-maintained on the PVC and are not refreshed by
pod startup. Git and Python remain available from the Hermes image and mise
shims on `PATH`.

## Deployment checks

Before merging, confirm a usable backup of the Hermes PVC: this changes the
shared backend and can migrate configuration or session databases.

After Flux deploys the PR, check:

1. All init containers complete and the gateway heartbeat stays fresh.
2. The Webapp and Dashboard require sign-in, and a permitted Kanidm account can
   complete each flow.
3. An account outside `hermes_admins` cannot obtain access.
4. The Webapp lists the intended profiles and can create a chat, stream a reply,
   and continue it after a browser reload. Check old-session adoption separately;
   visibility of history does not prove interactive continuation.
5. Hermex can authenticate against `hermes.bjw-s.dev` and continue the same test
   session; mobile compatibility is not established by a manifest render.
6. Hermes Desktop can sign in to `hermes.bjw-s.dev`, create a chat, stream a
   reply, and resume it after reconnecting.

## Rollback

Revert this PR through Git and let Flux deploy the previous manifests. This
removes the preview and restores the pinned backend image and managed config.
It does not undo persistent database migrations. If the old backend cannot read
migrated state, restore the verified pre-upgrade PVC backup with an explicitly
approved recovery procedure; do not delete or overwrite the PVC as a routine
rollback step.
