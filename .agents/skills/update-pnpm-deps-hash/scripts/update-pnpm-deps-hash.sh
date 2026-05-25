#!/usr/bin/env bash
set -euo pipefail

nix_file="${1:-assets.nix}"
build_attr="${2:-.#client}"

if [[ ! -f "$nix_file" ]]; then
  echo "Nix file not found: $nix_file" >&2
  exit 1
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

extract_got_hash() {
  sed -n 's/^[[:space:]]*got:[[:space:]]*//p' "$1" | tail -n 1
}

current_hash() {
  awk '
    /pnpmDeps = fetchPnpmDeps \{/ { in_block = 1 }
    in_block && /hash = "/ {
      match($0, /"[^"]+"/)
      if (RSTART > 0) {
        print substr($0, RSTART + 1, RLENGTH - 2)
        exit
      }
    }
    in_block && /^[[:space:]]*\};[[:space:]]*$/ { in_block = 0 }
  ' "$nix_file"
}

replace_hash() {
  local new_hash="$1"
  local out_file="$tmp_dir/assets.nix"

  awk -v new_hash="$new_hash" '
    /pnpmDeps = fetchPnpmDeps \{/ { in_block = 1 }
    in_block && !replaced && /hash = "/ {
      sub(/"[^"]+"/, "\"" new_hash "\"")
      replaced = 1
    }
    { print }
    in_block && /^[[:space:]]*\};[[:space:]]*$/ { in_block = 0 }
    END {
      if (!replaced) {
        exit 2
      }
    }
  ' "$nix_file" > "$out_file"

  mv "$out_file" "$nix_file"
}

for attempt in 1 2 3; do
  log_file="$tmp_dir/build-$attempt.log"

  if nix build "$build_attr" >"$log_file" 2>&1; then
    cat "$log_file"
    echo "Build succeeded for $build_attr"
    exit 0
  fi

  cat "$log_file" >&2

  got_hash="$(extract_got_hash "$log_file")"
  if [[ -z "$got_hash" ]]; then
    echo "Build failed without a parseable 'got:' hash. Leaving $nix_file unchanged." >&2
    exit 1
  fi

  old_hash="$(current_hash)"
  if [[ "$got_hash" == "$old_hash" ]]; then
    echo "Parsed hash matches the current value ($got_hash), but the build still failed." >&2
    exit 1
  fi

  replace_hash "$got_hash"
  echo "Updated $nix_file: $old_hash -> $got_hash"
done

echo "Exceeded retry limit while updating pnpmDeps.hash." >&2
exit 1
