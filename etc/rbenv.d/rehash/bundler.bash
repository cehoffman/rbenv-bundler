#!/usr/bin/env bash
#
# Copyright (C) 2011 Roy Liu
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#   * Redistributions of source code must retain the above copyright notice,
#     this list of conditions and the following disclaimer.
#   * Redistributions in binary form must reproduce the above copyright notice,
#     this list of conditions and the following disclaimer in the documentation
#     and/or other materials provided with the distribution.
#   * Neither the name of the author nor the names of any contributors may be
#     used to endorse or promote products derived from this software without
#     specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# The rbenv-bundler plugin delegate for "rbenv rehash".

source -- "$(dirname -- "$(dirname -- "${BASH_SOURCE[0]}")")/bundler/includes.sh"

[[ -n "$PLUGIN_DISABLED" ]] && return

# Read the cached bundle installation paths into an array.
cached_dirs_file="${PLUGIN_ROOT_DIR}/share/rbenv/bundler/paths"

if [[ ! -f "$cached_dirs_file" ]]; then
    mkdir -p -- "$(dirname -- "$cached_dirs_file")"
    touch -- "$cached_dirs_file"
fi

cached_dirs="$(cat -- "$cached_dirs_file")"$'\n'"$PWD"$'\n'
cached_dirs=$(echo -n "$cached_dirs" | uniq | sort -u)

ifs_save=$IFS

IFS=$'\n'
cached_dirs=($cached_dirs)
IFS=$ifs_save

acc=""

shopt -s nullglob
cd "$SHIM_PATH"

# As part of the "for" loop, this script sources itself to process each bundle installation path in turn.
for cached_dir in "${cached_dirs[@]}"; do
    bundle_root=$(get_bundle_root "$cached_dir")
    bundle_path=$(get_bundle_path "$bundle_root")

    [[ -n "$bundle_path" ]] || continue

    make_shims "$bundle_path"/ruby/*/bin/*

    acc="${acc}${bundle_root}"$'\n'
done

cd "$CUR_PATH"
shopt -u nullglob

echo -n "$acc" > "$cached_dirs_file"
