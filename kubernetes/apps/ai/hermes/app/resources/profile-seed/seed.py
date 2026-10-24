#!/usr/bin/env python3
"""Seed the default Hermes home and shared settings for named profiles."""

import io
import os
import secrets
import shutil
import stat
import tempfile
from pathlib import Path

from ruamel.yaml import YAML
from ruamel.yaml.comments import CommentedMap


DATA = Path("/opt/data")
SEED = Path("/seed")
TERMINAL_INIT = DATA / ".hermes-terminal-env.sh"
GATEWAY_BASE_URL = "http://127.0.0.1:8642"


def write_atomic(path: Path, content: str, mode: int) -> None:
    fd, temp = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent)
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as output:
            output.write(content)
        os.replace(temp, path)
        os.chmod(path, mode)
    finally:
        if os.path.exists(temp):
            os.unlink(temp)


def env_value(path: Path, name: str) -> str:
    if not path.exists():
        return ""
    values = [line.partition("=")[2] for line in path.read_text(encoding="utf-8").splitlines()
              if line.startswith(f"{name}=")]
    return values[-1].replace('"', "").replace("\r", "") if values else ""


def update_env(path: Path, remove: set[str], add: dict[str, str], *, remove_prefix: str = "") -> None:
    lines = path.read_text(encoding="utf-8").splitlines() if path.exists() else []
    lines = [line for line in lines if not (remove_prefix and line.startswith(remove_prefix))
             and not ("=" in line and line.partition("=")[0] in remove)]
    lines.extend(f"{name}={value}" for name, value in add.items())
    write_atomic(path, "\n".join(lines) + "\n", 0o600)


def update_terminal_config(path: Path) -> None:
    if not path.is_file():
        return
    yaml = YAML()
    yaml.preserve_quotes = True
    config = yaml.load(path.read_text(encoding="utf-8")) or CommentedMap()
    if not isinstance(config, dict):
        raise TypeError("profile config is not a mapping")

    terminal = config.get("terminal")
    if terminal is None:
        terminal = CommentedMap()
        config["terminal"] = terminal
    elif not isinstance(terminal, dict):
        raise TypeError("terminal config is not a mapping")

    init_files = terminal.get("shell_init_files")
    if init_files is None:
        terminal["shell_init_files"] = [str(TERMINAL_INIT)]
    elif isinstance(init_files, list):
        if str(TERMINAL_INIT) in init_files:
            return
        init_files.append(str(TERMINAL_INIT))
    else:
        raise TypeError("terminal.shell_init_files is not a list")

    output = io.StringIO()
    yaml.dump(config, output)
    write_atomic(path, output.getvalue(), stat.S_IMODE(path.stat().st_mode))


def seed() -> None:
    for name in ("config.yaml", "SOUL.md"):
        shutil.copyfile(SEED / name, DATA / name)

    write_atomic(TERMINAL_INIT,
                 'export PATH="/opt/data/.local/share/mise/shims:/opt/mise:'
                 '/opt/hermes/bin:/opt/hermes/.venv/bin:/opt/data/.local/bin:${PATH}"\n',
                 0o644)

    litellm_key = os.environ["LITELLM_API_KEY"]
    root_env = DATA / ".env"
    update_env(root_env, set(), {"LITELLM_API_KEY": litellm_key}, remove_prefix="LITELLM_")

    profile_dirs = sorted(path for path in (DATA / "profiles").glob("*") if path.is_dir())
    existing_keys = {profile: env_value(profile / ".env", "API_SERVER_KEY")
                     for profile in profile_dirs}
    reserved = set(existing_keys.values())
    root_key = env_value(root_env, "API_SERVER_KEY")
    used = {root_key} if root_key else set()

    for profile in profile_dirs:
        key = existing_keys[profile]
        if not key or key in used:
            key = secrets.token_hex(32)
            while key in reserved or key in used:
                key = secrets.token_hex(32)
        used.add(key)
        update_env(profile / ".env",
                   {"LITELLM_API_KEY", "API_SERVER_KEY", "HERMES_WEBUI_GATEWAY_BASE_URL"},
                   {"LITELLM_API_KEY": litellm_key,
                    "API_SERVER_KEY": key,
                    "HERMES_WEBUI_GATEWAY_BASE_URL": f"{GATEWAY_BASE_URL}/p/{profile.name}"})
        update_terminal_config(profile / "config.yaml")

    local_bin = DATA / ".local/bin"
    local_bin.mkdir(parents=True, exist_ok=True)
    mise = local_bin / "mise"
    if not mise.is_symlink() or os.readlink(mise) != "/opt/mise/mise":
        mise.unlink(missing_ok=True)
        mise.symlink_to("/opt/mise/mise")


if __name__ == "__main__":
    try:
        seed()
    except Exception as exc:
        # Parser errors can include credential-bearing file contents.
        raise SystemExit(f"Profile seed failed: {type(exc).__name__}") from None
