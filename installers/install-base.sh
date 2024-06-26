#!/bin/bash

PACKAGES=()

PACKAGES+=(wget)
PACKAGES+=(lsb-release)
PACKAGES+=(software-properties-common)
PACKAGES+=(gnupg)
PACKAGES+=(make)
PACKAGES+=(git)
PACKAGES+=(pkg-config)
PACKAGES+=(cmake)
PACKAGES+=(tar)

apt-get install -y --no-install-recommends "${PACKAGES[@]}"
