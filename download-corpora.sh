#!/bin/bash
set -x -e

if [ $# -lt 1 ]; then
  echo "Usage: ./download-corpora.sh <download-path>"
  exit 1
fi

targets=("mpi-add" "mpi-addmod" "mpi-div" "mpi-expmod" "mpi-mod"
         "mpi-mulmod" "mpi-sqr" "mpi-sqrmod" "mpi-sub" "mpi-submod"
         "mpi-invmod" "certDN" "hash" "quickder" "tls-client")

for target in "${targets[@]}"; do
  mkdir -p $target
  gsutil -m rsync gs://nss-corpus.clusterfuzz-external.appspot.com/libFuzzer/nss_$target/ $1/$target
done

