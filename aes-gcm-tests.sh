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

# Run all aes-gcm tests with the given configuration.
test() {
  export $1
  NSS_TESTS=cipher NSS_CYCLES=standard DOMSUF=localdomain "$PWD"/tests/all.sh
  ../dist/Debug/bin/freebl_gtest
  unset ${1:0:${#1}-2}
}

run_tests() {
  test # default config
  test "NSS_DISABLE_HW_AES=1"
  test "NSS_DISABLE_PCLMUL=1"
  test "NSS_DISABLE_AVX=1"
}

# Test performance.
echo "AES-GCM Performance" > ../performance.txt
echo "" >> ../performance.txt
performance() {
  echo "$1" >> ../performance.txt
  export $1
  ../dist/Release/bin/nss encrypt --cipher aes --in arch.iso --out arch.enc --key key --iv iv >> ../performance.txt 2>&1
  ../dist/Release/bin/nss decrypt --cipher aes --in arch.enc --out arch.dec --key key --iv iv >> ../performance.txt 2>&1
  if ! diff arch.iso arch.dec &> /dev/null; then
    exit 1
  fi
  rm -rf arch.enc arch.dec key iv
  echo "" >> ../performance.txt
  unset ${1:0:${#1}-2}
}

run_performance() {
  performance "default config" # default config
  performance "NSS_DISABLE_HW_AES=1"
  performance "NSS_DISABLE_PCLMUL=1"
  performance "NSS_DISABLE_AVX=1"
}

### Run Tests ###

export DYLD_LIBRARY_PATH="$libPathDebug"
export LD_LIBRARY_PATH="$libPathDebug"
export PATH="$PATH:$libPathDebug"

# Regular build.
./build.sh --test -c
run_tests

# Regular build (32-bit).
./build.sh --test -m32 -c
test

export DYLD_LIBRARY_PATH="$libPathRelease"
export LD_LIBRARY_PATH="$libPathRelease"
export PATH="$PATH:$libPathRelease"

# Regular build (opt).
./build.sh --opt -c --disable-tests
run_performance

# Regular build (32-bit, opt).
./build.sh --opt -m32 -c --disable-tests
run_performance
