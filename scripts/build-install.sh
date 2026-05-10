#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
	echo "usage: $0 /path/to/libfprint"
	exit 2
fi

repo="$1"
build_dir="${repo}/build-fpc9924"

if [[ ! -f "${repo}/meson.build" ]]; then
	echo "error: ${repo} does not look like a libfprint source tree"
	exit 1
fi

meson setup "${build_dir}" "${repo}" --wipe \
	-Ddrivers=fpcmoc \
	-Dintrospection=false \
	-Ddoc=false \
	-Dinstalled-tests=false
ninja -C "${build_dir}"
sudo meson install -C "${build_dir}"
sudo ldconfig
sudo udevadm control --reload-rules
sudo udevadm trigger

if systemctl list-unit-files | rg -q '^fprintd\.service'; then
	sudo systemctl restart fprintd
fi

echo "patched libfprint installed from ${repo}"
