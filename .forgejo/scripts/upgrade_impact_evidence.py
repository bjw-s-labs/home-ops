#!/usr/bin/env python3
"""Evidence provider: upstream upgrade impact for version-bump PRs.

Emits the action's evidence-provider JSON contract on stdout:
  {"severity": "info", "findings": [{"severity","message","source"}]}

Detects chart bumps (ocirepository.yaml tag changes) and container image bumps
(helmrelease.yaml image tag changes) in the PR diff, injects the deployment's
HelmRelease values, and fetches upstream GitHub release notes for the bumped
version range via authenticated `gh api`. Complements konflate: konflate shows
what changes in rendered manifests; this shows what changed upstream so the
model can cross-reference release notes against the values this repo sets.

Reads PR_NUMBER (and optionally GITHUB_REPOSITORY) from the environment, set
by the action. Read-only, advisory, never a gate: on any failure or a
non-bump PR it emits an empty findings list and exits 0.
"""
import json
import os
import re
import subprocess
import sys

PR = os.environ.get("PR_NUMBER", "").strip()
REPO = os.environ.get("GITHUB_REPOSITORY", "").strip()

MAX_RELEASES = 4
MAX_NOTES_BYTES = 3500
MAX_VALUES_BYTES = 4000
MAX_TOTAL_BYTES = 19000

_FILE_RE = re.compile(r"^\+\+\+ b/(.+)$")
_TAG_RE = re.compile(r"^([-+ ])\s*tag: (\S+)")
_URL_RE = re.compile(r"^[-+ ]\s*url: oci://(\S+)")
_REPOSITORY_RE = re.compile(r"^[-+ ]\s*repository: (\S+)")


def _emit(findings, severity="info"):
    print(json.dumps({"severity": severity, "findings": findings}))
    sys.exit(0)


def _clean_tag(tag):
    return tag.split("@", 1)[0].strip().strip('"')


def parse_bumps(diff_text):
    """Extract version bumps from a unified PR diff.

    Returns [{"path","kind","artifact","old","new"}] where kind is "chart"
    (ocirepository.yaml) or "image" (helmrelease.yaml). artifact may be None
    when the identifying url/repository line is outside the hunk; main()
    falls back to reading the file from the checkout.
    """
    bumps = []
    path = None
    image_repo = None
    old_tag = None
    for line in diff_text.splitlines():
        m = _FILE_RE.match(line)
        if m:
            path = m.group(1)
            image_repo = old_tag = None
            continue
        if path is None or not path.startswith("kubernetes/"):
            continue
        is_oci = path.endswith("ocirepository.yaml")
        is_hr = path.endswith("helmrelease.yaml")
        if not (is_oci or is_hr):
            continue
        m = _URL_RE.match(line)
        if m:
            # In OCIRepository manifests url: follows ref.tag, so the tag
            # pair is usually recorded before the url line is seen.
            for b in bumps:
                if b["path"] == path and b["kind"] == "chart" and b["artifact"] is None:
                    b["artifact"] = m.group(1)
            continue
        m = _REPOSITORY_RE.match(line)
        if m:
            image_repo = m.group(1).strip('"')
            continue
        m = _TAG_RE.match(line)
        if not m:
            continue
        sign, tag = m.group(1), _clean_tag(m.group(2))
        if sign == "-":
            old_tag = tag
        elif sign == "+" and old_tag is not None:
            if tag != old_tag:
                bumps.append({
                    "path": path,
                    "kind": "chart" if is_oci else "image",
                    "artifact": None if is_oci else image_repo,
                    "old": old_tag,
                    "new": tag,
                })
            old_tag = None
    return bumps


def parse_version(text):
    m = re.search(r"\d+(?:\.\d+)+", text or "")
    if not m:
        return None
    return tuple(int(p) for p in m.group(0).split("."))


def select_releases(releases, old, new):
    """Releases with version in (old, new], newest first, capped.

    Returns (selected, omitted_count). Unparseable `old` widens the lower
    bound; unparseable `new` selects nothing (can't bound the range).
    """
    lo, hi = parse_version(old), parse_version(new)
    if hi is None:
        return [], 0
    picked = []
    for r in releases:
        if r.get("draft") or r.get("prerelease"):
            continue
        v = parse_version(r.get("tag_name", ""))
        if v is None or v > hi:
            continue
        if lo is not None and v <= lo:
            continue
        picked.append((v, r))
    picked.sort(key=lambda t: t[0], reverse=True)
    return [r for _, r in picked[:MAX_RELEASES]], max(0, len(picked) - MAX_RELEASES)


_SOURCE_RE = re.compile(r"\[source\]\(https://github\.com/([^/)]+/[^/)#?]+)")


def resolve_repo_candidates(artifact, pr_body=""):
    cands = []
    parts = (artifact or "").split("/")
    if len(parts) >= 3 and "." in parts[0]:
        cands.append(f"{parts[1]}/{parts[2]}")
        if len(parts) > 3 and f"{parts[1]}/{parts[-1]}" not in cands:
            cands.append(f"{parts[1]}/{parts[-1]}")
    for m in _SOURCE_RE.finditer(pr_body or ""):
        slug = m.group(1).removesuffix(".git")
        if slug not in cands:
            cands.append(slug)
    return cands


def flatten_values(tree, prefix=""):
    """Flatten a nested values dict to dotted leaf paths; lists are leaves."""
    if not isinstance(tree, dict):
        return {}
    flat = {}
    for key, val in tree.items():
        path = f"{prefix}.{key}" if prefix else str(key)
        if isinstance(val, dict) and val:
            flat.update(flatten_values(val, path))
        else:
            flat[path] = val
    return flat


def values_drift(old_defaults, new_defaults, our_values):
    """Diff chart default values old→new and intersect with keys we set.

    A key we set that disappeared from the defaults is the headline signal:
    it may have been renamed upstream, silently turning our override into a
    no-op that renders identically.
    """
    old = flatten_values(old_defaults)
    new = flatten_values(new_defaults)
    ours = flatten_values(our_values)
    removed = [k for k in old if k not in new]
    added = [k for k in new if k not in old]
    changed = [k for k in old if k in new and old[k] != new[k]]
    return {
        "added": len(added),
        "removed": len(removed),
        "changed": len(changed),
        "removed_set_keys": sorted(k for k in removed if k in ours),
        "changed_set_keys": sorted((k, old[k], new[k]) for k in changed if k in ours),
    }


def _truncate(text, limit_bytes, marker=""):
    if len(text.encode()) <= limit_bytes:
        return text
    out = text.encode()[:limit_bytes].decode("utf-8", "replace").rstrip("�")
    return out + ("\n" + marker if marker else "")


def build_findings(ctxs):
    findings = []
    for ctx in ctxs:
        b = ctx["bump"]
        head = f"{b['artifact'] or b['path']} {b['old']} → {b['new']} ({b['kind']} bump)"
        if ctx.get("hr_text"):
            findings.append({
                "severity": "info",
                "message": (
                    f"Deployment configuration for {head}. These are the HelmRelease "
                    "values this repo sets — cross-reference upstream changes against "
                    "them and flag anything that affects configured behavior:\n\n"
                    f"```yaml\n{_truncate(ctx['hr_text'], MAX_VALUES_BYTES, '# [truncated]')}\n```"
                ),
                "source": ctx["hr_path"],
            })
        rels = ctx.get("releases") or []
        if rels:
            parts = []
            for r in rels:
                notes = _truncate((r.get("body") or "").strip(), MAX_NOTES_BYTES,
                                  f"[truncated — see {r.get('html_url', '')}]")
                parts.append(f"### {r.get('tag_name')} — {r.get('name') or ''}\n{notes}")
            skipped = ctx.get("skipped", 0)
            more = (f"\n\n({skipped} more releases in range omitted for size — see the "
                    "releases page.)") if skipped else ""
            findings.append({
                "severity": "info",
                "message": (
                    f"Upstream release notes for {head} — check them against the "
                    "HelmRelease values above:\n\n" + "\n\n".join(parts) + more
                ),
                "source": f"https://github.com/{ctx['repo_slug']}/releases",
            })
        drift = ctx.get("drift")
        if drift:
            totals = (f"{drift['added']} added / {drift['changed']} changed / "
                      f"{drift['removed']} removed")
            lines = []
            for k in drift["removed_set_keys"]:
                lines.append(f"- `{k}` — set in the HelmRelease but no longer in the "
                             "chart defaults; likely renamed or removed upstream, so "
                             "the override may now be a silent no-op. Verify against "
                             "the new chart.")
            for k, old_v, new_v in drift["changed_set_keys"]:
                lines.append(f"- `{k}` — upstream default changed {old_v!r} → {new_v!r} "
                             "(this repo overrides it, so behavior is unchanged, but "
                             "the upstream intent shifted).")
            if lines:
                body = "\n".join(lines)
            else:
                body = ("none intersect the values this repo sets — no configured "
                        "value was renamed, removed, or re-defaulted.")
            findings.append({
                "severity": "info",
                "message": (
                    f"Chart default values drift for {head} ({totals}): {body}"
                ),
                "source": b["path"],
            })
        if not rels and ctx.get("repo_slug") is None:
            findings.append({
                "severity": "info",
                "message": (
                    f"No upstream release notes retrievable for {head} — upstream "
                    "impact is unverified; treat this as a known blind spot and "
                    "do not guess changelog contents."
                ),
                "source": b["path"],
            })
    return findings


def fit_budget(findings):
    while findings and len(json.dumps(
            {"severity": "info", "findings": findings}).encode()) > MAX_TOTAL_BYTES:
        longest = max(findings, key=lambda f: len(f["message"].encode()))
        size = len(longest["message"].encode())
        if size <= 1000:
            findings.remove(longest)
            continue
        longest["message"] = _truncate(longest["message"], size // 2,
                                       "[truncated for size]")
    return findings


def _run(cmd, timeout=25):
    r = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
    if r.returncode != 0:
        raise RuntimeError(f"{' '.join(cmd[:3])} failed: {r.stderr.strip()[:200]}")
    return r.stdout


def _repo_args():
    return ["--repo", REPO] if REPO else []


def fetch_releases(slug):
    data = json.loads(_run(["gh", "api", f"repos/{slug}/releases?per_page=50"]))
    return data if isinstance(data, list) else []


def parse_helm_show_values(output):
    """Parse `helm show values` stdout; helm v4 prefixes Pulled:/Digest: lines
    before a `---` document separator."""
    import yaml
    lines = output.splitlines()
    for i, line in enumerate(lines):
        if line.startswith("---"):
            output = "\n".join(lines[i:])
            break
    data = yaml.safe_load(output)
    return data if isinstance(data, dict) else {}


def compute_chart_drift(bump, hr_text):
    """Default-values drift for a chart bump; None if unavailable.

    Requires helm and PyYAML; both are preinstalled on ubuntu-latest runners.
    Any failure (missing tools, unpullable chart, unparseable YAML) skips the
    signal rather than failing the provider.
    """
    try:
        import yaml
        defaults = {}
        for ver in (bump["old"], bump["new"]):
            defaults[ver] = parse_helm_show_values(_run(
                ["helm", "show", "values", f"oci://{bump['artifact']}",
                 "--version", ver], timeout=60))
        ours = (yaml.safe_load(hr_text) or {}).get("spec", {}).get("values", {})
        return values_drift(defaults[bump["old"]], defaults[bump["new"]], ours)
    except Exception as exc:
        print(f"upgrade-impact: drift skipped for {bump['artifact']}: {exc}",
              file=sys.stderr)
        return None


def main():
    if not PR.isdigit():
        _emit([])
    try:
        bumps = parse_bumps(_run(["gh", "pr", "diff", PR, *_repo_args()], timeout=30))
        if not bumps:
            _emit([])
        try:
            pr_body = json.loads(_run(
                ["gh", "pr", "view", PR, *_repo_args(), "--json", "body"]))["body"] or ""
        except Exception:
            pr_body = ""
        ctxs = []
        for b in bumps:
            if b["artifact"] is None and b["kind"] == "chart":
                try:
                    with open(b["path"], encoding="utf-8") as f:
                        m = re.search(r"url: oci://(\S+)", f.read())
                    if m:
                        b["artifact"] = m.group(1)
                except OSError:
                    pass
            ctx = {"bump": b, "repo_slug": None}
            hr_path = os.path.join(os.path.dirname(b["path"]), "helmrelease.yaml")
            try:
                with open(hr_path, encoding="utf-8") as f:
                    ctx["hr_text"] = f.read()
                ctx["hr_path"] = hr_path
            except OSError:
                pass
            for slug in resolve_repo_candidates(b["artifact"], pr_body):
                try:
                    selected, skipped = select_releases(
                        fetch_releases(slug), b["old"], b["new"])
                except Exception:
                    continue
                if selected:
                    ctx.update(repo_slug=slug, releases=selected, skipped=skipped)
                    break
            if b["kind"] == "chart" and b["artifact"] and ctx.get("hr_text"):
                drift = compute_chart_drift(b, ctx["hr_text"])
                if drift is not None:
                    ctx["drift"] = drift
            ctxs.append(ctx)
        _emit(fit_budget(build_findings(ctxs)))
    except Exception as exc:  # advisory: never fail the review
        print(f"upgrade-impact evidence provider: {exc}", file=sys.stderr)
        _emit([])


if __name__ == "__main__":
    main()
