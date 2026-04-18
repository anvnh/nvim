#!/usr/bin/env sh

set -eu

tmp_base="${TMPDIR:-/tmp}/nvim-config-validate"
mkdir -p "$tmp_base/cache" "$tmp_base/state"

export XDG_CACHE_HOME="$tmp_base/cache"
export XDG_STATE_HOME="$tmp_base/state"

NVIM_APPNAME="${NVIM_APPNAME:-nvim}" \
    nvim -i NONE --headless "+checkhealth" "+qa"
