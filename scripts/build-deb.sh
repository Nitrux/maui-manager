#! /bin/bash

set -x

### Update sources

wget -qO /etc/apt/sources.list.d/nitrux-main-compat-repo.list https://raw.githubusercontent.com/Nitrux/iso-tool/development/configs/files/sources/nitrux-repo.list

wget -qO /etc/apt/sources.list.d/nitrux-testing-repo.list https://raw.githubusercontent.com/Nitrux/iso-tool/development/configs/files/sources/nitrux-testing-repo.list

curl -L https://packagecloud.io/nitrux/repo/gpgkey | apt-key add -;
curl -L https://packagecloud.io/nitrux/compat/gpgkey | apt-key add -;
curl -L https://packagecloud.io/nitrux/testing/gpgkey | apt-key add -;

apt -qq update

### Download Source

git clone --depth 1 --branch $MAUIMAN_BRANCH https://invent.kde.org/maui/mauiman.git

rm -rf {LICENSE,README.md}

### Compile Source

mkdir -p build && cd build

ls -lh \
	/usr/lib/x86_64-linux-gnu/cmake/ \
	/usr/lib/x86_64-linux-gnu/cmake/MauiMan

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
	-DCMAKE_INSTALL_LIBDIR=lib/x86_64-linux-gnu ../mauiman/

ls -lh \
	/usr/lib/x86_64-linux-gnu/cmake/ \
	/usr/lib/x86_64-linux-gnu/cmake/MauiMan

make -j$(nproc)

ls -lh \
	/usr/lib/x86_64-linux-gnu/cmake/ \
	/usr/lib/x86_64-linux-gnu/cmake/MauiMan

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
	--requires=libc6,libqt5core5a \
	--nodoc \
	--strip=no \
	--stripso=yes \
	--reset-uids=yes \
	--deldesc=yes
