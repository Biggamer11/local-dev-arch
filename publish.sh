#!/usr/bin/env bash
set -euo pipefail
repo_dir=${LOCAL_DEV_REPO_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/local-dev/arch/x86_64}
signing_dir=${LOCAL_DEV_SIGNING_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/local-dev/signing}
key=865598DF7228194559CCDBE0A145D35EABFD8722
(($#)) || { echo 'Usage: publish.sh PACKAGE.pkg.tar.zst [...]' >&2; exit 2; }
mkdir -p -- "$repo_dir"
files=()
for file in "$@"; do
  [[ -f $file && $file == *.pkg.tar.zst ]] || { echo 'Expected a built Arch package' >&2; exit 2; }
  target="$repo_dir/$(basename -- "$file")"
  [[ $(readlink -f -- "$file") == $(readlink -f -- "$target") ]] || cp -- "$file" "$target"
  gpg --homedir "$signing_dir" --batch --yes --local-user "$key" --detach-sign "$target"
  files+=("$target")
done
if command -v repo-add >/dev/null; then
  GNUPGHOME="$signing_dir" repo-add --sign --key "$key" "$repo_dir/local-dev.db.tar.gz" "${files[@]}"
else
  distrobox enter --name codex-tools -- env GNUPGHOME="$signing_dir" repo-add --sign --key "$key" "$repo_dir/local-dev.db.tar.gz" "${files[@]}"
fi
gpg --homedir "$signing_dir" --armor --export "$key" > "$repo_dir/local-dev-signing-key.asc"
assets=("$repo_dir/local-dev.db" "$repo_dir/local-dev.db.sig" "$repo_dir/local-dev.files" "$repo_dir/local-dev.files.sig" "$repo_dir/local-dev-signing-key.asc")
for file in "${files[@]}"; do assets+=("$file" "$file.sig"); done
if command -v gh >/dev/null; then
  gh release upload repository --repo Biggamer11/local-dev-arch --clobber "${assets[@]}"
else
  distrobox enter --name codex-tools -- gh release upload repository --repo Biggamer11/local-dev-arch --clobber "${assets[@]}"
fi
