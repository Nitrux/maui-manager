#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause
# Copyright 2025-2026 <Nitrux Latinoamericana S.C. <hello@nxos.org>>


# -- Exit on errors.

set -euo pipefail

# MauiKit software MUST be built with CMake and ECM; NEVER use Meson.

# -- Prepare source.

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"
export PATH="/usr/lib/qt6/bin:$PATH"
PACKAGE_VERSION="${PACKAGE_VERSION:?PACKAGE_VERSION must be supplied by CI}"
TARGET_ARCH="${TARGET_ARCH:-$(dpkg --print-architecture)}"
DEB_HOST_MULTIARCH="${DEB_HOST_MULTIARCH:-$(dpkg-architecture -qDEB_HOST_MULTIARCH)}"

# -- Download Source

git clone --depth 1 --branch "${MAUIMAN_BRANCH}" https://github.com/Nitrux/maui-manager-src.git "$repo_root/maui-manager-src"
source_dir="$repo_root/maui-manager-src"

# -- Configure build.

build_dir="$repo_root/build"
stage_dir="$build_dir/package"
rm -rf "$build_dir" "$stage_dir"
mkdir -p "$build_dir"

# -- Compile Source

cmake -S "$source_dir" -B "$build_dir" \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DKDE_INSTALL_LIBDIR="lib/$DEB_HOST_MULTIARCH" \
    -DCMAKE_BUILD_TYPE=Release
cmake --build "$build_dir" --parallel "$(nproc)"

# -- Install source to DESTDIR.

DESTDIR="$stage_dir" cmake --install "$build_dir"

# -- Create DEBIAN control file.

mkdir -p "$stage_dir/DEBIAN"
cat > "$stage_dir/DEBIAN/control" <<CONTROL
Package: maui-manager
Version: ${PACKAGE_VERSION}
Section: libs
Priority: optional
Architecture: ${TARGET_ARCH}
Maintainer: uri_herrera@nxos.org
Provides: maui-manager
Depends: libqt6qml6,libc6,libqt6concurrent6,libqt6core6t64,libqt6dbus6,libqt6gui6,libqt6network6,libqt6opengl6,libqt6openglwidgets6,libqt6printsupport6,libqt6sql6,libqt6widgets6,libqt6xml6
Description: maui-manager
 maui-manager
CONTROL

# -- Create .deb.

dpkg-deb --build --root-owner-group "$stage_dir" "$build_dir/maui-manager_${PACKAGE_VERSION}_${TARGET_ARCH}.deb"
