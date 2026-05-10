#!/usr/bin/env bash
set -euo pipefail

echo "== lsusb probe =="
lsusb | rg -i '10a5:9924|finger|fpc' || true

echo "== fprintd-enroll =="
fprintd-enroll "$USER"

echo "== fprintd-list =="
fprintd-list "$USER"

echo "== fprintd-verify =="
fprintd-verify "$USER"
