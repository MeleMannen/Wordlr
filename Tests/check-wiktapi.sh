#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
check_dir=$(mktemp -d)
trap 'rm -rf "$check_dir"' EXIT
swiftc -parse-as-library Wordlr/WiktDefinition.swift Wordlr/WiktDefinitionProvider.swift Tests/WiktDefinitionProviderChecks.swift -o "$check_dir/check-wiktapi"
"$check_dir/check-wiktapi"
