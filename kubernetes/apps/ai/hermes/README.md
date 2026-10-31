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

Profile configuration and `SOUL.md` live on the PVC and are managed in the app.
The init script provisions shared credentials and terminal tooling, but never
copies either file. Existing profile settings and SOUL files remain in place;
remove any old text claiming they are overwritten at startup through the app.

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
removes the preview and restores the pinned backend image and seed config.
It does not undo persistent database migrations. If the old backend cannot read
migrated state, restore the verified pre-upgrade PVC backup with an explicitly
approved recovery procedure; do not delete or overwrite the PVC as a routine
rollback step.
