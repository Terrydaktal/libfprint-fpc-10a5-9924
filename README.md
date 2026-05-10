# fpc9924-libfprint-patched

Patched `libfprint` workflow for Fingerprint Cards sensor `10a5:9924` (Honor MagicBook path), in the same delivery style as packaged/patched driver repos.

This repo contains:
- a patch against upstream `libfprint` (`fpcmoc`) for experimental `10a5:9924` support
- scripts to apply, build, and install the patched library

## Project Structure

```text
fpc9924-libfprint-patched/
├── patches/
│   └── 0001-fpcmoc-add-10a5-9924-experimental-support.patch
├── scripts/
│   ├── apply-patch.sh
│   ├── build-install.sh
│   └── smoke-test.sh
└── README.md
```

## What The Patch Changes

- Adds USB ID `10a5:9924` to `fpcmoc`.
- Adds 9924-specific session-init steps in open/init path:
  - `0x08` indicate S0
  - `0x01` init (event-driven)
  - `0x12` session prepare
  - `0x14` session/auth blob read
  - `0x90` session arm
  - then normal DB load flow
- Enables type-2 identity handling (`16-byte binary identity`) for list/enroll/identify/delete on 9924.
- Keeps legacy behavior for existing `fpcmoc` devices.

## Prerequisites

On Debian/Ubuntu/Mint (example packages):

```bash
sudo apt-get update
sudo apt-get install -y \
  git meson ninja-build pkg-config build-essential \
  libglib2.0-dev libgusb-dev libudev-dev libnss3-dev \
  libcairo2-dev libpam0g-dev libdbus-1-dev gtk-doc-tools
```

## Usage

### 1) Apply patch to a fresh `libfprint` checkout

```bash
./scripts/apply-patch.sh /path/to/libfprint
```

### 2) Build + install patched libfprint

```bash
./scripts/build-install.sh /path/to/libfprint
```

### 3) Smoke test with fprintd

```bash
./scripts/smoke-test.sh
```

## Validation Flow

After install:

```bash
fprintd-enroll "$USER"
fprintd-list "$USER"
fprintd-verify "$USER"
```

To clear one print via desktop stack:

```bash
fprintd-delete "$USER"
```

## Notes

- This is an experimental patch path based on reverse-engineered traffic and live prototype behavior.
- If identify returns transport errors after suspend/resume, power-cycle the sensor path (`reboot`) and retry.
- If enrollment fails mid-way, rerun enrollment immediately; this device may require cleanup rounds after interrupted captures.
