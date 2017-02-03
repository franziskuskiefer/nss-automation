#!/bin/bash

bug=${1:-1334127}
dir=${2:-/home/franziskus/Code/automation/mozilla-inbound}
cd $dir
hg purge .
hg revert .
hg up default-tip
hg pull -u
hg book nss-uplift -f
# update NSS
tag=$(hg id https://hg.mozilla.org/projects/nss#default)
python2 client.py update_nss $tag
hg addremove
hg commit -m "Bug $bug - land NSS $tag, r=me"
# build
./mach build
if [ $? -ne 0 ]; then
  echo "======= Build failed! Manual intervention necessary! ======="
  exit 1
fi
# update CA telemetry hash table
cd security/manager/tools/
LD_LIBRARY_PATH=../../../obj-x86_64-pc-linux-gnu/dist/bin/ ../../../obj-x86_64-pc-linux-gnu/dist/bin/xpcshell genRootCAHashes.js $PWD/../ssl/RootHashes.inc
if [ $? -ne 0 ]; then
  echo "======= Updating CA table failed! Manual intervention necessary! ======="
  exit 1
fi
cd -
# get everything that happened in the meantime
hg up default-tip
hg pull -u
hg up nss-uplift
hg rebase -d default-tip
hg book -d nss-uplift
echo "=> PUSH"
hg push -r .
