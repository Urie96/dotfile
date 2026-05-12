#!/usr/bin/env bash

args=(--backup-suffix .bak)

if [ -n "${TERMUX_VERSION:-}" ]; then
  args+=(--relative)
fi

python3 ./main.py "${args[@]}"
