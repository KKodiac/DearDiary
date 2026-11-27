#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
secrets_path=Tuist/Plugins/DependencyPlugin/ProjectDescriptionHelpers/Project+Secrets.swift
if [ ! -f "$secrets_path" ]; then
    cp Configuration/Project+Secrets.swift.example "$secrets_path"
    printf '%s\n' "Created local placeholder configuration at $secrets_path."
fi
mise trust
mise install
mise exec -- tuist install
mise exec -- tuist generate --no-open
