#!/usr/bin/env bash

set -v -e -x

# Update packages.
export DEBIAN_FRONTEND=noninteractive
apt-get -y update && apt-get -y upgrade

# Need this to add keys for PPAs below.
apt-get install -y --no-install-recommends apt-utils

apt_packages=()
apt_packages+=('ca-certificates')
apt_packages+=('curl')
apt_packages+=('xz-utils')
apt_packages+=('mercurial')
apt_packages+=('git')

# Install packages.
apt-get -y update
apt-get install -y --no-install-recommends ${apt_packages[@]}

# Download clang.
curl -LO http://releases.llvm.org/3.9.1/clang+llvm-3.9.1-x86_64-linux-gnu-ubuntu-16.04.tar.xz
curl -LO http://releases.llvm.org/3.9.1/clang+llvm-3.9.1-x86_64-linux-gnu-ubuntu-16.04.tar.xz.sig
# Verify the signature.
gpg --keyserver pool.sks-keyservers.net --recv-keys B6C8F98282B944E3B0D5C2530FC3042E345AD05D
gpg --verify *.tar.xz.sig
# Install into /usr/local/.
tar xJvf *.tar.xz -C /usr/local --strip-components=1
# Cleanup.
rm *.tar.xz*

locale-gen en_US.UTF-8
dpkg-reconfigure locales

# Cleanup.
rm -rf ~/.ccache ~/.cache
apt-get autoremove -y
apt-get clean
apt-get autoclean
rm $0

