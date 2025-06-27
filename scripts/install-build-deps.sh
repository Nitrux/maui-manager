#!/usr/bin/env bash

#############################################################################################################################################################################
#   The license used for this file and its contents is: BSD-3-Clause                                                                                                        #
#                                                                                                                                                                           #
#   Copyright <2025> <Uri Herrera <uri_herrera@nxos.org>>                                                                                                                   #
#                                                                                                                                                                           #
#   Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:                          #
#                                                                                                                                                                           #
#    1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.                                        #
#                                                                                                                                                                           #
#    2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer                                      #
#       in the documentation and/or other materials provided with the distribution.                                                                                         #
#                                                                                                                                                                           #
#    3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software                    #
#       without specific prior written permission.                                                                                                                          #
#                                                                                                                                                                           #
#    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,                      #
#    THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS                  #
#    BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE                 #
#    GOODS OR SERVICES; LOSS OF USE, DATA,   OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,                      #
#    STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.   #
#############################################################################################################################################################################


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
    "${KEYRING_DIR}/kde_neon-archive-keyring.gpg" \
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
