# libfprint-fpc-10a5-9924

Patched `libfprint` workflow for Fingerprint Cards sensor `10a5:9924`, specifically for the Honor MagicBook 14 Pro (2025), in the same delivery style as packaged/patched driver repos.

This repo contains:
- a patch against upstream `libfprint` (`fpcmoc`) for experimental `10a5:9924` support
- scripts to apply, build, and install the patched library

## Project Structure

```text
libfprint-fpc-10a5-9924/
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

## Install

```bash
# 1. Install build deps
sudo apt-get update
sudo apt-get install -y \
  git meson ninja-build cmake pkg-config build-essential \
  libglib2.0-dev libgusb-dev libudev-dev libnss3-dev \
  libcairo2-dev libpam0g-dev libdbus-1-dev libsystemd-dev \
  libssl-dev libgirepository1.0-dev gobject-introspection \
  gtk-doc-tools

# 2. Clone this patch repo
git clone https://github.com/Terrydaktal/libfprint-fpc-10a5-9924.git
cd libfprint-fpc-10a5-9924

# 3. Clone upstream libfprint source
git clone --depth 1 https://gitlab.freedesktop.org/libfprint/libfprint.git ./libfprint-9924

# 4. Apply this repo's patch to upstream libfprint
./scripts/apply-patch.sh ./libfprint-9924

# 5. Build and install patched libfprint
./scripts/build-install.sh ./libfprint-9924

# 6. Restart fprintd
sudo systemctl restart fprintd

# 7. Enroll and verify
fprintd-enroll -f right-index-finger "$USER"
fprintd-list "$USER"
fprintd-verify -f right-index-finger "$USER"
```

Delete behavior in `fprintd`:

```bash
# delete all enrolled fingerprints for the user
fprintd-delete "$USER"

# delete a single enrolled finger
fprintd-delete "$USER" -f right-index-finger
```

## Security / TLS Status

- Windows uses additional secure-auth/TLS-related plumbing (notably around `0x64/0x65/0x6C/0x6D`) in the vendor stack.
- This patch targets a working Linux `libfprint`/`fprintd` flow (enroll/list/verify/delete) for `10a5:9924` and does not claim full Windows secure-auth parity.
- The implemented path includes the required session/auth initialization (`0x12` + `0x14` + `0x90`) and is validated functionally on target hardware.
- If full vendor-secure parity is required, deeper reverse engineering of the Windows secure-auth key/handshake flow is still needed.

## Notes

- This is an experimental patch path based on reverse-engineered traffic and live prototype behavior.
- If identify returns transport errors after suspend/resume, power-cycle the sensor path (`reboot`) and retry.
- If enrollment fails mid-way, rerun enrollment immediately; this device may require cleanup rounds after interrupted captures.
