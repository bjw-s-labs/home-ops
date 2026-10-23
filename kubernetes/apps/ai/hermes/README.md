# Hermes Agent

Single-replica [Hermes Agent](https://github.com/NousResearch/hermes-agent) with
[Hermes WebUI](https://github.com/nesquena/hermes-webui) on `https://hermes.bjw-s.dev`
(`envoy-internal` only).

## How it runs

- The agent container runs `hermes -p default gateway run --no-supervise` as its foreground process under Kubernetes.
  The explicit root profile keeps the host gateway on `/opt/data` even when WebUI changes the PVC's sticky
  `active_profile` selection. It starts the cron scheduler and loopback-only API server. The WebUI is another container
  in the same pod and sends browser chat through the gateway runs API. No messaging platforms are configured.
- The agent's startup/liveness/readiness probes require a cron ticker heartbeat
  (`/opt/data/cron/ticker_heartbeat`) younger than 5 minutes. WebUI probes check `/health` on port `8787`.
- Both containers run as UID/GID `10000` and share the Hermes PVC. WebUI starts rootless with writable `emptyDir`
  mounts for `/app`, `/uv_cache`, and `/tmp`.
- `/opt/data` (`HERMES_HOME`) is the kopiur-backed PVC that holds sessions, memories, skills, `workspace/`, logs, and the
  mutable `config.yaml`/`.env`. WebUI mounts the same PVC at `/home/hermeswebui/.hermes` and stores its own sessions in
  `webui/`. The agent's previous dashboard chat sessions are not migrated into WebUI's session store. WebUI reads
  active TUI sessions from the shared profile databases; sessions whose messages were all made inactive cannot be
  imported through the normal CLI session bridge.
- A Kubernetes image volume mounts the pinned agent image's `/opt/hermes` source read-only in WebUI at the path
  expected by its entrypoint. Kubernetes `v1.37.1` supports image-volume `subPath`. WebUI installs dependencies from PyPI at pod
  startup; `pypi.org` and `files.pythonhosted.org` are allowed egress for this purpose. The WebUI image and agent
  image should be updated together because WebUI imports agent internals.
- Git only sets what every profile must share, through Hermes' managed scope: `app/resources/managed/` (ConfigMap
  `hermes-managed`) is mounted read-only at `/etc/hermes/config.yaml` and `/etc/hermes/.env` in both containers. It pins
  the LiteLLM provider and model catalog. Pinned keys cannot be changed from WebUI.
- WebUI reads each profile's `config.yaml` directly and does not apply Hermes' managed overlay when choosing a chat
  provider. Each profile, including newly created ones, must also have `model.provider: custom:litellm` and
  `model.base_url: http://litellm.ai.svc.cluster.local:4000/v1` in its mutable config. The profile's `model.default`
  remains its own choice. Without those routing fields, WebUI can submit a model to the gateway as a generic custom
  provider, which resolves through OpenRouter and times out under this pod's egress policy.
- Everything else is managed in WebUI and lives on the PVC: profiles and their models, `SOUL.md`, skills, MCP
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
- WebUI login uses native OIDC against Kanidm: a confidential client with PKCE, defined in
  `app/kanidmoauth2client.yaml`. kaniop generates `hermes-kanidm-oauth2-credentials`, and the client secret reaches
  WebUI as `HERMES_WEBUI_OIDC_CLIENT_SECRET`. The callback is `/api/auth/oidc/callback`. WebUI requires the
  `hermes_access=admin` claim, issued only to `hermes_admins` members. Keep all four required OIDC variables
  (`issuer`, `client_id`, `allow_claim`, `allow_values`) set: WebUI otherwise disables OIDC login.
- WebUI refuses OIDC endpoints whose DNS answers are private IPs. Cluster DNS normally resolves `idm.bjw-s.dev` to
  the internal gateway, so the pod maps that hostname to the public ingress IP in `hostAliases`. The IP is maintained
  in `kubernetes/apps/network/external-dns/ovh/public-edge-dnsendpoint.yaml`; update both places if it changes.
  Egress to the public IP is limited to HTTPS with SNI `idm.bjw-s.dev`. Cilium checks SNI, while Envoy routes on the
  HTTP Host header, so a deliberate mismatch could still reach another route on that gateway. The issuer URL, TLS
  hostname verification, and Kanidm group gate remain the same. This public-IP workaround is temporary while we wait
  for [hermes-webui PR #6164](https://github.com/nesquena/hermes-webui/pull/6164) to land in a pinned release; review
  its final configuration and remove the workaround when private issuer endpoints are supported.
- The gateway API remains on loopback. At startup, a short WebUI command reads the generated `API_SERVER_KEY` from
  the shared `.env`, exports it as `HERMES_WEBUI_GATEWAY_API_KEY` for gateway chat and Tasks/System status, then executes
  the upstream WebUI entrypoint. The key is not stored in Git or printed in logs.

## Prerequisites

- Membership of the Kanidm group `hermes_admins` (managed in the `kanidm-provision` repository) grants full
  WebUI and agent (shell) access. Hermes has no roles.

## Security boundaries

- No Kubernetes API access: the ServiceAccount token isn't mounted, no RBAC bindings exist, and the pod carries
  `egress.policy.home.arpa/block-all`, so the cluster-wide `allow-default-egress` policy does not apply.
- Egress is limited to DNS (cluster-wide policy), LiteLLM `:4000`, PyPI `:443` for WebUI startup, the Kanidm
  public ingress IP on `:443` with SNI `idm.bjw-s.dev`, and `envoy-external` `:10443` for Forgejo. The agent also
  has limited GitHub egress; there is no general internet access.
- Ingress is limited to `envoy-internal` on `:8787`.
- The agent's shell runs as the same user as WebUI, with write access to `/opt/data`. The managed scope and
  the env scrub are defense in depth, not a sandbox: a determined agent can read process environments and edit its own
  state. Treat the LiteLLM virtual key as readable by the agent; it is limited to the models listed in
  `litellmvirtualkey.yaml`.

## Future: isolated coding sandbox (not deployed)

1. Hermes keeps running here; `terminal.backend` switches from `local` to `ssh`.
2. Commands run on a dedicated VM or dev environment as an unprivileged user without sudo or Kubernetes credentials.
3. Egress gains only `:22` to that host; the SSH key comes from 1Password via an ExternalSecret.
4. Hermes pushes branches and opens pull requests with a narrowly scoped token on the sandbox host.
5. A human reviews and merges into protected branches; Flux performs the deployment.
