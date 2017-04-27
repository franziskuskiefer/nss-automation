#!/usr/bin/env bash

docker run -v $PWD:/home/worker/nss --rm -ti franziskus/clang-format-service:latest
