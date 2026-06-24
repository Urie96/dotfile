"""Thin proxy: receives remote kitty calls, resolves target_window_id, and
delegates to `coding-agent-status write`.  No cache logic lives here."""

import argparse
from typing import List

from kittens.tui.handler import result_handler


def main(args: List[str]):
    pass


@result_handler(no_ui=True)
def handle_result(args: List[str], answer: str, target_window_id: int, boss):
    parser = argparse.ArgumentParser(
        description="Relay coding agent status update", add_help=False, exit_on_error=False
    )
    parser.add_argument("command", choices=["update"])
    parser.add_argument("--event", choices=["start", "end"], required=True)
    parser.add_argument("--agent", default="coding-agent")
    parser.add_argument("--cwd", default="")
    parser.add_argument("--added", type=int, default=0)
    parser.add_argument("--deleted", type=int, default=0)
    parser.add_argument("--numstat-b64", default="")

    try:
        parsed = parser.parse_args(args[1:])
    except SystemExit:
        return True

    import os as _os
    import subprocess

    bin_path = _os.path.expanduser("~/bin/coding-agent-status")
    subprocess.run(
        [
            bin_path,
            "write",
            "--window-id", str(target_window_id),
            "--event", parsed.event,
            "--agent", parsed.agent,
            "--cwd", parsed.cwd,
            "--added", str(parsed.added),
            "--deleted", str(parsed.deleted),
            "--numstat-b64", parsed.numstat_b64,
        ],
        timeout=10,
    )
    return True
