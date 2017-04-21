#!/bin/bash
set -e -x -v
# Test all possible AES-GCM implementations.

nssRepo=${1:-"https://hg.mozilla.org/projects/nss"}
nsprRepo="https://hg.mozilla.org/projects/nspr"
folder=${2:-"/tmp/aes-gmc-test"}
libPathDebug="../dist/Debug/lib/"
libPathRelease="../dist/Release/lib/"

# Get the code.
mkdir -p "$folder"
cd "$folder"
if [ ! -d "nss" ]; then
  hg clone $nssRepo nss
fi
if [ ! -d "nspr" ]; then
  hg clone "$nsprRepo" nspr
fi
cd nss

# Prepare test files.
if [ ! -f "arch.iso" ]; then
  wget franziskuskiefer.de/data/arch.iso
fi

# Run all tests.
test() {
  ../dist/Debug/bin/bltest -T -m aes_gcm -d "$PWD"/cmd/bltest
  ../dist/Debug/bin/freebl_gtest
}

# Test performance.
echo "Performance" > ../performance.txt
performance() {
  echo "$1\n" >> ../performance.txt
  ../dist/Release/bin/nss encrypt --cipher aes --in arch.iso --out arch.enc --key key --iv iv &> "../$1"
  ../dist/Release/bin/nss decrypt --cipher aes --in arch.enc --out arch.dec --key key --iv iv &>> "../$1"
  if ! diff arch.iso arch.dec &> /dev/null; then
    exit 1
  fi
  rm -rf arch.enc arch.dec key iv
}

### Run Tests ###

export DYLD_LIBRARY_PATH="$libPathDebug"
export LD_LIBRARY_PATH="$libPathDebug"
export PATH="$PATH:$libPathDebug"

# Regular build.
./build.sh --test -c
test

# Disable hardware AES.
./build.sh --test --disable-hw-aes -c
test

# Disable hardware GCM.
./build.sh --test --disable-hw-gcm -c
test

# Regular build (32-bit).
./build.sh --test -m32 -c
test

# Disable hardware AES (32-bit).
./build.sh --test --disable-hw-aes -c -m32
test

# Disable hardware GCM (32-bit).
./build.sh --test --disable-hw-gcm -c -m32
test

export DYLD_LIBRARY_PATH="$libPathRelease"
export LD_LIBRARY_PATH="$libPathRelease"
export PATH="$PATH:$libPathRelease"

# Regular build (opt).
./build.sh --opt -c --disable-tests
performance "reg"

# Disable hardware AES (opt).
./build.sh --opt --disable-hw-aes -c --disable-tests
performance "d-hw-aes"

# Disable hardware GCM (opt).
./build.sh --opt --disable-hw-gcm -c --disable-tests
performance "d-hw-gcm"

# Regular build (32-bit, opt).
./build.sh --opt -m32 -c --disable-tests
performance "x86"

# Disable hardware AES (32-bit, opt).
./build.sh --opt --disable-hw-aes -c -m32 --disable-tests
performance "d-hw-aes-x86"

# Disable hardware GCM (32-bit, opt).
./build.sh --opt --disable-hw-gcm -c -m32 --disable-tests
performance "d-hw-gcm-x86"

