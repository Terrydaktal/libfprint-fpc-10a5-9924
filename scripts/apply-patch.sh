#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
	echo "usage: $0 /path/to/libfprint"
	exit 2
fi

repo="$1"
patch_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../patches" && pwd)"
patch_file="${patch_dir}/0001-fpcmoc-add-10a5-9924-experimental-support.patch"

if [[ ! -d "${repo}/.git" ]]; then
	echo "error: ${repo} is not a git checkout"
	exit 1
fi

if [[ ! -f "${patch_file}" ]]; then
	echo "error: patch file missing: ${patch_file}"
	exit 1
fi

git -C "${repo}" apply --check "${patch_file}"
git -C "${repo}" apply "${patch_file}"
echo "patch applied: ${patch_file}"
