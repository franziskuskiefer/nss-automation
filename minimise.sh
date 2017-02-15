#!/bin/bash
set -e

if [ $# -lt 3 ]; then
  echo "Usage: ./minimise.sh <super-oldcorpus> <super-newcorpus> <folder-with-options>"
  exit 1
fi
oldcorpus=$1
newcorpus=$2
optionsfolder=$3
mkdir -p $newcorpus

for corpus in $(find $oldcorpus/* -type d | grep -v '/\.'); do
  new=$newcorpus/$(basename $corpus)
  options="$optionsfolder/$(basename $corpus).options"
  max_len=$(grep "max_len" $options)
  max_len=$(cut -d "=" -f 2 <<< "$max_len" | xargs)
  mkdir -p $new   
  LD_LIBRARY_PATH=~/Code/dist/Debug/lib/ ~/Code/dist/Debug/bin/nssfuzz-$(basename $corpus) -max_len=$max_len -merge=1 $new $corpus
done

