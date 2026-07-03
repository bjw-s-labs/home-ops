#!/usr/bin/env python3
"""Evidence provider: konflate rendered-diff for the PR under review.

Emits the action's evidence-provider JSON contract on stdout:
  {"severity": "info", "findings": [{"severity","message","source"}]}

Reads PR_NUMBER from the environment (set by the action). Targets konflate's
read-only MCP endpoint (KONFLATE_MCP_URL). Read-only, advisory, never a gate:
on any failure or an untracked PR it emits an empty findings list and exits 0
so it can never block a review.
"""
import json, os, sys, urllib.error, urllib.request

URL = os.environ.get("KONFLATE_MCP_URL", "http://konflate.flux-system.svc.cluster.local:8080/mcp")
PR = os.environ.get("PR_NUMBER", "").strip()
SID = None

def _emit(findings, severity="info"):
    print(json.dumps({"severity": severity, "findings": findings}))
    sys.exit(0)

def call(method, params=None, notif=False):
    global SID
    body = {"jsonrpc": "2.0", "method": method}
    if not notif:
        body["id"] = 1
    if params is not None:
        body["params"] = params
    req = urllib.request.Request(URL, data=json.dumps(body).encode(), method="POST")
    req.add_header("Content-Type", "application/json")
    req.add_header("Accept", "application/json, text/event-stream")
    # An explicit User-Agent is required: urllib's default ("Python-urllib/x")
    # trips Cloudflare's Browser Integrity Check (Error 1010, HTTP 403) at the
    # edge, even when the hostname is WAF-allowlisted. Any real UA passes.
    req.add_header("User-Agent", "ai-pr-reviewer-konflate/1.0")
    tok = os.environ.get("KONFLATE_MCP_TOKEN", "").strip()
    if tok:
        req.add_header("Authorization", f"Bearer {tok}")
    if SID:
        req.add_header("Mcp-Session-Id", SID)
    try:
        with urllib.request.urlopen(req, timeout=20) as r:
            sid = r.headers.get("Mcp-Session-Id")
            if sid:
                SID = sid
            raw = r.read().decode()
    except urllib.error.HTTPError as e:
        # Surface the edge/app body (e.g. a Cloudflare error page) so a future
        # block explains itself instead of a bare "HTTP Error 403".
        detail = e.read().decode("utf-8", "replace")[:200].replace("\n", " ")
        raise RuntimeError(f"HTTP {e.code} from {URL}: {detail}") from None
    if notif:
        return None
    for line in raw.splitlines():
        if line.startswith("data:"):
            return json.loads(line[5:].strip())
    return None

def _text(resp):
    out = []
    for c in (resp or {}).get("result", {}).get("content", []):
        if c.get("type") == "text":
            out.append(c["text"])
    return "\n".join(out).strip()

def main():
    if not PR.isdigit():
        _emit([])  # no PR context — nothing to add
    try:
        call("initialize", {"protocolVersion": "2025-06-18", "capabilities": {},
                            "clientInfo": {"name": "konflate-evidence", "version": "0"}})
        call("notifications/initialized", notif=True)
        summary = _text(call("tools/call", {"name": "get_pr_summary", "arguments": {"number": int(PR)}}))
        diff = _text(call("tools/call", {"name": "get_pr_diff", "arguments": {"number": int(PR)}}))
    except Exception as exc:  # advisory: never fail the review
        print(f"konflate evidence provider: {exc}", file=sys.stderr)
        _emit([])

    findings = []
    src = f"http://konflate.flux-system.svc.cluster.local:8080/mcp/#/pr/{PR}"

    # konflate returns a plain sentinel when there's no usable diff yet —
    # PR not tracked ("No pull request #N is tracked.") or render still pending
    # ("has no rendered diff yet", "Still rendering"). Emit nothing in those
    # cases rather than presenting a placeholder as evidence.
    _SKIP = ("no pull request", "is tracked", "no rendered diff",
             "still rendering", "has no rendered")

    def _no_evidence(t):
        low = (t or "").lower()
        return (not t) or any(s in low for s in _SKIP)

    if _no_evidence(diff):
        _emit([])
    findings.append({
        "severity": "info",
        "message": "konflate rendered Flux diff (post-kustomize/Helm Kubernetes YAML — "
                   "the resources Flux will actually apply, not the raw template diff):\n\n"
                   f"{diff}",
        "source": src,
    })
    if summary and not _no_evidence(summary):
        findings.append({"severity": "info", "message": summary, "source": src})
    _emit(findings)

if __name__ == "__main__":
    main()
