# Hermes Agent

Single-replica [Hermes Agent](https://github.com/NousResearch/hermes-agent) with the built-in web dashboard and chat on
`https://hermes.bjw-s.dev` (`envoy-internal` only).

## How it runs

- The image's s6-overlay `/init` stays PID 1 and supervises two services: the dashboard (`HERMES_DASHBOARD=1`) and the
  gateway, which `gateway run` registers before execing a `sleep infinity` heartbeat. No messaging platforms are
  configured, so the gateway only runs the cron scheduler and a loopback-only API server. Dashboard chat runs
  `hermes --tui` over a PTY/WebSocket inside the dashboard process.
- Startup and liveness probes require both the dashboard's `/api/health` and a cron ticker heartbeat
  (`/opt/data/cron/ticker_heartbeat`) younger than 5 minutes. A dead gateway or a hung scheduler restarts the container,
  so stopping the gateway from the dashboard also triggers a restart.
- The container runs as UID/GID `10000`, the image's `hermes` user. The image refuses any other non-root UID.
- `/opt/data` (`HERMES_HOME`) is the kopiur-backed PVC that holds sessions, memories, skills, `workspace/`, logs, and the
  mutable `config.yaml`/`.env`. `/run` and `/tmp` are emptyDirs; the root filesystem is read-only.
- Git only sets what every profile must share, through Hermes' managed scope: `app/resources/managed/` (ConfigMap
  `hermes-managed`) is mounted read-only at `/etc/hermes/config.yaml` and `/etc/hermes/.env`. It pins the LiteLLM
  provider and model catalog and the dashboard login (Kanidm OIDC only). Pinned keys cannot be changed from the dashboard.
- Everything else is managed in the dashboard and lives on the PVC: profiles and their models, `SOUL.md`, skills, MCP
  servers, toolsets, approvals and auxiliary models. Nothing in Git overwrites it.
- The `config-migrate` init container runs the image's config migration on every start (the image's own attempt fails
  as non-root).
- The gateway (cron jobs) resolves credentials per profile and never falls back to the pod environment. A profile that
  runs cron jobs or uses `${OPENAI_API_KEY}` (e.g. in MCP headers) needs this in its `config.yaml`; the `hermes-litellm`
  Secret is mounted at `/mnt/secrets/litellm` for it (tmpfs, not on the PVC):

  ```yaml
  secrets:
    command:
      enabled: true
      command: printf 'OPENAI_API_KEY=%s\n' "$(cat /mnt/secrets/litellm/key)"
  ```

- Home Assistant is reachable as LiteLLM's `home_assistant` MCP server
  (`http://litellm.ai.svc.cluster.local:4000/mcp/home_assistant`, header `Authorization: Bearer ${OPENAI_API_KEY}`). It
  runs as `kubernetes/apps/home-automation/home-assistant/mcp` (ha-mcp) and holds the Home Assistant token; Hermes'
  virtual key reaches it through the `hermes` LiteLLM team. Use a short server name in Hermes (e.g. `ha`): tool names
  are prefixed with it and capped at 64 characters.
- The model provider is the in-cluster LiteLLM proxy. The `LiteLLMVirtualKey` mints a model-scoped key into the
  `hermes-litellm` Secret, exposed as `OPENAI_API_KEY`. That name is on Hermes' subprocess credential scrub list, so
  terminal and `execute_code` children don't inherit it.
- Dashboard login uses native self-hosted OIDC against Kanidm: a confidential client with PKCE, defined in
  `app/kanidmoauth2client.yaml`. kaniop generates `hermes-kanidm-oauth2-credentials`, and the client secret reaches
  Hermes as `HERMES_DASHBOARD_OIDC_CLIENT_SECRET`. A non-loopback dashboard without an auth
  provider refuses to start, so a broken auth configuration fails the probes instead of serving an open dashboard.

## Prerequisites

- Membership of the Kanidm group `hermes_admins` (managed in the `kanidm-provision` repository) is the only
  authorization gate. Hermes has no roles, so every member gets full dashboard and agent (shell) access.

## Security boundaries

- No Kubernetes API access: the ServiceAccount token isn't mounted, no RBAC bindings exist, and the pod carries
  `egress.policy.home.arpa/block-all`, so the cluster-wide `allow-default-egress` policy does not apply.
- Egress is limited to DNS (cluster-wide policy), LiteLLM `:4000`, and `envoy-external` `:10443` for Kanidm (in-cluster
  DNS resolves `*.bjw-s.dev` to the gateway). The gateway rule only allows TLS with SNI `idm.bjw-s.dev`; Cilium checks
  the SNI, while Envoy routes on the HTTP Host header, so a deliberate SNI/Host mismatch could still reach other
  external routes. There is no general internet access, so web, browser, package installs, and `git clone` from the
  internet don't work.
- Ingress is limited to `envoy-internal` on `:9119`.
- The agent's shell runs as the same user as the dashboard, with write access to `/opt/data`. The managed scope and
  the env scrub are defense in depth, not a sandbox: a determined agent can read process environments and edit its own
  state. Treat the LiteLLM virtual key as readable by the agent; it is limited to the models listed in
  `litellmvirtualkey.yaml`.

## Future: isolated coding sandbox (not deployed)

1. Hermes keeps running here; `terminal.backend` switches from `local` to `ssh`.
2. Commands run on a dedicated VM or dev environment as an unprivileged user without sudo or Kubernetes credentials.
3. Egress gains only `:22` to that host; the SSH key comes from 1Password via an ExternalSecret.
4. Hermes pushes branches and opens pull requests with a narrowly scoped token on the sandbox host.
5. A human reviews and merges into protected branches; Flux performs the deployment.
