import argparse
import base64
import json
import os
import tempfile
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, List

from kittens.tui.handler import result_handler
from kitty.boss import Boss

STATE_DIR = Path(os.path.expanduser("~/.cache/coding-agent-status"))
STATE_FILE = STATE_DIR / "status.json"


def main(args: List[str]):
    pass


def now_iso() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z")


def relative_time(iso: str) -> str:
    if not iso:
        return ""
    try:
        s = iso.replace("Z", "+00:00")
        then = datetime.fromisoformat(s)
        diff = datetime.now(timezone.utc) - then
        seconds = int(abs(diff.total_seconds()))
    except (ValueError, TypeError):
        return ""
    if seconds < 60:
        return f"{seconds}s"
    if seconds < 3600:
        return f"{seconds // 60}m"
    if seconds < 86400:
        return f"{seconds // 3600}h"
    return f"{seconds // 86400}d"


def empty_state() -> dict:
    return {"version": 1, "windows": {}}


def read_state() -> dict:
    try:
        with STATE_FILE.open("r", encoding="utf-8") as f:
            data = json.load(f)
        if not isinstance(data, dict):
            return empty_state()
        windows = data.get("windows")
        if not isinstance(windows, dict):
            data["windows"] = {}
        data.setdefault("version", 1)
        return data
    except FileNotFoundError:
        return empty_state()
    except Exception:
        return empty_state()


def write_state(state: dict) -> None:
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    fd, tmp_name = tempfile.mkstemp(prefix="status.", suffix=".json", dir=str(STATE_DIR))
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as f:
            json.dump(state, f, ensure_ascii=False, indent=2, sort_keys=True)
            f.write("\n")
        os.replace(tmp_name, STATE_FILE)
    finally:
        try:
            os.unlink(tmp_name)
        except FileNotFoundError:
            pass


def decode_numstat(value: str) -> str:
    if not value:
        return ""
    try:
        return base64.b64decode(value.encode("ascii"), validate=True).decode("utf-8", "replace")
    except Exception:
        return ""


def clean_closed_windows(state: dict, boss: Boss) -> dict:
    live_ids = {str(window_id) for window_id in boss.window_id_map.keys()}
    windows = state.get("windows", {})
    if not isinstance(windows, dict):
        windows = {}
    state["windows"] = {window_id: item for window_id, item in windows.items() if window_id in live_ids}
    return state


def format_status_tsv(state: dict) -> str:
    windows: Dict[str, dict] = state.get("windows", {}) if isinstance(state.get("windows"), dict) else {}

    GREEN = "\x1b[38;5;114m"
    RED = "\x1b[38;5;203m"
    ICON_ACTIVE = "\x1b[38;5;114m"
    ICON_IDLE = "\x1b[38;5;245m"
    DIM = "\x1b[38;5;245m"
    RESET = "\x1b[0m"
    ICON_WORKING = "\U000F0109"
    ICON_IDLE_CHAR = "\U000F08AA"

    rows = []
    for window_id, item in windows.items():
        if not isinstance(item, dict):
            continue
        working = bool(item.get("working"))
        added = int(item.get("added") or 0)
        deleted = int(item.get("deleted") or 0)
        cwd = item.get("cwd") or ""
        cwd = cwd.rstrip("/").rsplit("/", 1)[-1] or cwd
        updated = item.get("updatedAt") or ""
        rows.append([window_id, working, cwd, added, deleted, updated])

    rows.sort(key=lambda r: r[5] or "", reverse=True)

    # Build display lines: one TSV column per row, spacing handled entirely in Python
    max_cwd = max((len(r[2]) for r in rows), default=0)
    max_diff_plain = 0
    diff_plains = []
    for r in rows:
        d = "+%d -%d" % (r[3], r[4])
        diff_plains.append(d)
        if len(d) > max_diff_plain:
            max_diff_plain = len(d)

    lines = []
    for row, diff_plain in zip(rows, diff_plains):
        window_id, working, cwd, added, deleted, updated = row
        icon_color = ICON_ACTIVE if working else ICON_IDLE
        icon_char = ICON_WORKING if working else ICON_IDLE_CHAR

        cwd_padded = cwd.ljust(max_cwd)
        diff = "+%d -%d" % (added, deleted)
        diff_padded = diff.ljust(max_diff_plain)
        rel = relative_time(updated)

        line = "%s%s%s  %s  %s%s%s %s%s%s  %s%s%s" % (
            icon_color, icon_char, RESET,
            cwd_padded,
            GREEN, diff_padded.split(" ")[0], RESET,
            RED, diff_padded.split(" ")[1], RESET,
            DIM, rel, RESET,
        )
        lines.append("\t".join([window_id, line, updated]))
    return "\n".join(lines)


@result_handler(no_ui=True)
def handle_result(args: List[str], answer: str, target_window_id: int, boss: Boss):
    parser = argparse.ArgumentParser(description="Track coding agent status", add_help=False, exit_on_error=False)
    subparsers = parser.add_subparsers(dest="command", required=True)

    update = subparsers.add_parser("update", add_help=False)
    update.add_argument("--event", choices=["start", "end"], required=True)
    update.add_argument("--agent", default="coding-agent")
    update.add_argument("--cwd", default="")
    update.add_argument("--added", type=int, default=0)
    update.add_argument("--deleted", type=int, default=0)
    update.add_argument("--numstat-b64", default="")

    subparsers.add_parser("status", add_help=False)

    try:
        parsed = parser.parse_args(args[1:])
    except SystemExit:
        return ""

    state = clean_closed_windows(read_state(), boss)

    if parsed.command == "status":
        write_state(state)
        return format_status_tsv(state)

    window_id = str(target_window_id)
    state["windows"][window_id] = {
        "windowId": target_window_id,
        "agent": parsed.agent,
        "cwd": parsed.cwd,
        "working": parsed.event == "start",
        "event": parsed.event,
        "added": parsed.added,
        "deleted": parsed.deleted,
        "numstat": decode_numstat(parsed.numstat_b64),
        "updatedAt": now_iso(),
    }
    write_state(state)
    return True
