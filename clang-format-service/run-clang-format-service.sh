#!/usr/bin/env bash

docker run -v $PWD:/home/worker/nss --rm -ti clang-format
