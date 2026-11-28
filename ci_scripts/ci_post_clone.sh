#!/bin/sh
set -eu

cd "${CI_PRIMARY_REPOSITORY_PATH:-$(dirname "$0")/..}"
export PATH="$HOME/.local/bin:$PATH"

if ! command -v mise >/dev/null 2>&1; then
    installer="$(mktemp)"
    trap 'rm -f "$installer"' EXIT
    curl -fsSL https://mise.run -o "$installer"
    sh "$installer"
fi

printf '%s\n' 'Running DearDiary Tuist setup'
./Scripts/setup.sh
