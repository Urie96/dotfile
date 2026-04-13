#!/usr/bin/env python3
"""
Dotfile installer: symlinks files from this repo into $HOME.
Only individual files are linked (not directories).
Symlinks are recorded in .symlink_record for cleanup on subsequent runs.
"""

import os
import platform
from pathlib import Path

REPO_DIR = Path(__file__).resolve().parent
SOURCE_DIR = REPO_DIR / "home"
RECORD_FILE = REPO_DIR / ".symlink_record"
HOME = Path.home()
SYSTEM = platform.system()

# Skip patterns (gitignore-style, root = ./home):
#   - ending with '/'        → matches directories only
#   - leading '/'            → anchored to SOURCE_DIR root (./home)
#   - containing '/' in middle → path pattern, relative to SOURCE_DIR
#   - plain name (no '/')    → matches files AND directories at any depth
SKIP_PATTERNS = [
    ".gitignore",
    ".gitattributes",
    "shell.nix",
    ".DS_Store",
    ".direnv/",
    "__pycache__/",
    ".git/",
    ".git-crypt/",
]

if SYSTEM == "Linux":
    SKIP_PATTERNS.extend(["/Library", "/.config/raycast"])


def _match_skip_pattern(name: str, rel_dir: str, is_dir: bool) -> bool:
    """Check if a filesystem entry matches any SKIP_PATTERNS rule.

    Args:
        name:    basename of the entry (e.g. "__pycache__")
        rel_dir: relative directory from SOURCE_DIR, using '/' separator
                 (empty string for items directly under SOURCE_DIR)
        is_dir:  True if the entry is a directory
    """
    for pat in SKIP_PATTERNS:
        dir_only = pat.endswith("/")
        clean = pat.rstrip("/")

        if dir_only and not is_dir:
            continue

        # leading '/' means anchored to SOURCE_DIR root
        anchored = clean.startswith("/")
        clean = clean.lstrip("/")

        if "/" in clean:
            # Path pattern
            full_rel = f"{rel_dir}/{name}" if rel_dir else name
            if anchored:
                # /a/b — only match at SOURCE_DIR root
                if full_rel == clean:
                    return True
            else:
                # a/b — match at any depth
                if full_rel == clean or full_rel.endswith("/" + clean):
                    return True
        elif anchored:
            # Anchored name — only match directly under SOURCE_DIR root
            if rel_dir == "" and name == clean:
                return True
        else:
            # Unanchored name — match at any depth
            if name == clean:
                return True
    return False


def read_record() -> set[str]:
    """Read previously recorded symlink targets (absolute paths)."""
    if not RECORD_FILE.exists():
        return set()
    entries: set[str] = set()
    for line in RECORD_FILE.read_text().splitlines():
        line = line.strip()
        if line:
            entries.add(line)
    return entries


def write_record(targets: set[str]) -> None:
    """Write the full set of symlink targets to the record file."""
    RECORD_FILE.write_text("\n".join(sorted(targets)) + "\n")


def collect_source_files() -> dict[Path, Path]:
    """
    Walk SOURCE_DIR and build a mapping of:
        source_file (in repo) -> target_file (in $HOME)
    Only regular files are collected (no directories, no symlinks).
    """
    mapping: dict[Path, Path] = {}
    for root, dirs, files in os.walk(SOURCE_DIR):
        root_path = Path(root)
        rel_dir = str(root_path.relative_to(SOURCE_DIR).as_posix())
        if rel_dir == ".":
            rel_dir = ""

        # Prune directories that match a skip pattern
        dirs[:] = [d for d in dirs if not _match_skip_pattern(d, rel_dir, is_dir=True)]

        for fname in files:
            if _match_skip_pattern(fname, rel_dir, is_dir=False):
                continue
            src = root_path / fname
            if not src.is_file():
                continue
            # Compute the relative path under SOURCE_DIR, then join with HOME
            rel = src.relative_to(SOURCE_DIR)
            dst = HOME / rel
            mapping[src] = dst
    return mapping


def ensure_parent_dir(dst: Path) -> None:
    """Create parent directories of dst if they don't exist."""
    dst.parent.mkdir(parents=True, exist_ok=True)


def make_link(src: Path, dst: Path) -> bool:
    """
    Create a symlink at dst pointing to src.
    Returns True if a new symlink was created, False if it already existed
    and pointed to the correct target.
    If dst exists and is not a symlink pointing to src, print a warning and skip.
    """
    # Already a correct symlink?
    if dst.is_symlink():
        try:
            if os.readlink(dst) == str(src):
                return False  # already linked
        except OSError:
            pass
        # Symlink points elsewhere — remove it
        dst.unlink()
    elif dst.exists():
        # A real file/directory is in the way
        print(f"  ⚠ 跳过 (目标已存在且非软链接): {dst}")
        return False

    ensure_parent_dir(dst)
    os.symlink(str(src), str(dst))
    return True


def main() -> None:
    if not SOURCE_DIR.exists():
        print(f"错误: 源目录不存在: {SOURCE_DIR}")
        exit(1)

    old_record = read_record()
    current_mapping = collect_source_files()  # src -> dst
    current_targets: set[str] = {str(dst) for dst in current_mapping.values()}

    # ---- Phase 1: remove stale symlinks ----
    removed = 0
    stale = old_record - current_targets
    for target_str in sorted(stale):
        target = Path(target_str)
        if target.is_symlink():
            target.unlink()
            removed += 1
            print(f"  🗑 删除死链接: {target}")

    # ---- Phase 2: create / verify symlinks ----
    added = 0
    for src, dst in sorted(current_mapping.items()):
        if make_link(src, dst):
            added += 1
            print(f"  ✅ 新建软链接: {dst} -> {src}")

    # ---- Phase 3: write updated record ----
    write_record(current_targets)

    # ---- Summary ----
    total = len(current_targets)
    print()
    print(f"{'=' * 50}")
    print(f"  新增: {added} 个")
    print(f"  删除: {removed} 个")
    print(f"  当前总共: {total} 个软链接")
    print(f"{'=' * 50}")


if __name__ == "__main__":
    main()
