#!/bin/bash

set -eu

### Update sources

mkdir -p /etc/apt/keyrings

curl -fsSL https://packagecloud.io/nitrux/mauikit/gpgkey | gpg --dearmor -o /etc/apt/keyrings/nitrux_mauikit-archive-keyring.gpg

cat <<EOF > /etc/apt/sources.list.d/nitrux-mauikit.list
deb [signed-by=/etc/apt/keyrings/nitrux_mauikit-archive-keyring.gpg] https://packagecloud.io/nitrux/mauikit/debian/ trixie main
EOF

apt -q update

### Download Source

git clone --depth 1 --branch $MAUIMAN_BRANCH https://invent.kde.org/maui/mauiman.git

rm -rf {LICENSE,LICENSES,docs,.gitignore,.kde-ci.yml,README.md,metainfo.yaml}

### Compile Source

mkdir -p build && cd build

cmake \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DENABLE_BSYMBOLICFUNCTIONS=OFF \
	-DQUICK_COMPILER=ON \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_SYSCONFDIR=/etc \
	-DCMAKE_INSTALL_LOCALSTATEDIR=/var \
	-DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON \
	-DCMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY=ON \
	-DCMAKE_INSTALL_RUNSTATEDIR=/run "-GUnix Makefiles" \
	-DCMAKE_VERBOSE_MAKEFILE=ON \
	-DCMAKE_INSTALL_LIBDIR=/usr/lib/x86_64-linux-gnu ../mauiman/

make -j"$(nproc)"

make install

### Run checkinstall and Build Debian Package

>> description-pak printf "%s\n" \
	'A free and modular front-end framework for developing user experiences.' \
	'' \
	'This package contains the Maui Manager shared library, the server and' \
	'the public API.' \
	'' \
	''

checkinstall -D -y \
	--install=no \
	--fstrans=yes \
	--pkgname=maui-manager-git \
	--pkgversion=$PACKAGE_VERSION \
	--pkgarch=amd64 \
	--pkgrelease="1" \
	--pkglicense=LGPL-3 \
	--pkggroup=libs \
	--pkgsource=mauiman \
	--pakdir=. \
	--maintainer=uri_herrera@nxos.org \
	--provides=maui-manager-git \
	--requires="libc6,libqt6concurrent6,libqt6core6t64,libqt6dbus6,libqt6gui6,libqt6network6,libqt6opengl6,libqt6openglwidgets6,libqt6printsupport6,libqt6sql6,libqt6widgets6,libqt6xml6" \
	--nodoc \
	--strip=no \
	--stripso=yes \
	--reset-uids=yes \
	--deldesc=yes
