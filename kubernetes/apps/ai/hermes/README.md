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
- Configuration lives in Git; state lives on the PVC. `app/resources/` mirrors where files end up:
  - `managed/` (ConfigMap `hermes-managed`) is Hermes' managed scope, mounted read-only at `/etc/hermes/config.yaml` and
    `/etc/hermes/.env`. Its keys (provider, disabled toolsets, approvals, terminal, cron scheduler, dashboard auth) override
    every profile and cannot be changed from the dashboard. Cron-spawned agents cannot schedule further jobs.
  - `data/` (ConfigMap `hermes-data`) is copied over `/opt/data` by the `config` init container on every start, which then
    runs the image's config migration. It holds what Hermes reads straight from its home rather than through the managed
    scope: each profile's `config.yaml` (model, `mcp_servers`, `secrets`, `skills.disabled`) and `SOUL.md`. A new profile
    needs its files under `data/profiles/<name>/` plus matching keys in the generator and the `seed` volume's `items`.
  - Dashboard edits to configuration are refused (managed keys) or reset on restart. Chats, memory, cron jobs and your own
    skills are state and persist.
- The gateway (cron jobs) resolves credentials per profile and does not fall back to the pod environment, so each
  profile's `secrets.command` reads `OPENAI_API_KEY` from the `hermes-litellm` Secret mounted at `/mnt/secrets/litellm`
  (tmpfs, not on the PVC).
- Profiles: `default` (the base home) and `home-assistant`, both on `chatgpt/gpt-6-luna`. Only `home-assistant` has an MCP
  server: `ha`, which is LiteLLM's `home_assistant` server. That server runs as
  `kubernetes/apps/home-automation/home-assistant/mcp` (ha-mcp) and holds the Home Assistant token; Hermes only uses its
  virtual key, which reaches the server through the `hermes` LiteLLM team.
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
