#!/usr/bin/env bash
set -euo pipefail

exec "$(dirname "$0")/scripts/test-sia32-r0.sh" "$@"
