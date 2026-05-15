#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
	echo "usage: $0 /path/to/libfprint"
	exit 2
fi

repo="$1"
build_dir="${repo}/build-fpc9924"
meson_prefix="${MESON_PREFIX:-}"
meson_libdir="${MESON_LIBDIR:-}"

if [[ ! -f "${repo}/meson.build" ]]; then
	echo "error: ${repo} does not look like a libfprint source tree"
	exit 1
fi

if [[ -z "${meson_prefix}" || -z "${meson_libdir}" ]]; then
	if [[ -r /etc/os-release ]]; then
		# shellcheck disable=SC1091
		. /etc/os-release
	fi
fi

if [[ -z "${meson_prefix}" ]]; then
	if [[ "${ID:-}" == "fedora" ]]; then
		meson_prefix="/usr"
	else
		meson_prefix="/usr/local"
	fi
fi

if [[ -z "${meson_libdir}" ]]; then
	if [[ "${ID:-}" == "fedora" && "${meson_prefix}" == "/usr" ]]; then
		meson_libdir="lib64"
	else
		meson_libdir="lib"
	fi
fi

meson setup "${build_dir}" "${repo}" --wipe \
	--prefix="${meson_prefix}" \
	--libdir="${meson_libdir}" \
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
