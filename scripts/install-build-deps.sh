#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause
# Copyright 2024-2025 <Nitrux Latinoamericana S.C. <hello@nxos.org>>


# -- Exit on errors.

set -xe


# -- Check if running as root.

if [ "$EUID" -ne 0 ]; then
    APT_COMMAND="sudo apt"
else
    APT_COMMAND="apt"
fi


# -- Add third-aprty repository keys.

add_repo_key_and_source() {
    local key_id="$1"
    local keyring_file="$2"
    local source_file="$3"
    local source_content="$4"

    if ! gpg --list-keys "$key_id" &>/dev/null; then
        gpg --batch --keyserver hkps://keyserver.ubuntu.com --recv-keys "$key_id"
    fi

    if ! [ -f "$keyring_file" ] || ! gpg --quiet --with-colons --import-options show-only --import "$keyring_file" | grep -q "$key_id"; then
        gpg --batch --yes --export "$key_id" | gpg --dearmor -o "$keyring_file"
    fi

    if ! grep -Fxq "$source_content" "$source_file" 2>/dev/null; then
        echo "$source_content" > "$source_file"
    fi
}

add_repo_key_and_source \
    "E6D4736255751E5D" \
    "/etc/apt/keyrings/kde_neon-archive-keyring.gpg" \
    "/etc/apt/sources.list.d/neon-repo.list" \
    "deb [signed-by=/etc/apt/keyrings/kde_neon-archive-keyring.gpg] https://origin.archive.neon.kde.org/stable/ jammy main"


# -- Install build packages.

$APT_COMMAND update -q
$APT_COMMAND install -y - --no-install-recommends \
    appstream \
    automake \
    autotools-dev \
    checkinstall \
    cmake \
    extra-cmake-modules \
    gettext \
    qt6-base-dev
