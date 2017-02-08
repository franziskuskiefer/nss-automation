#!/bin/bash

# create ci user and home
mkdir /home/ci
useradd -d /home/ci ci
chown -R ci:ci /home/ci

# update and set-up docker
apt-get update
apt-get upgrade -y
apt-get install -y --no-install-recommends docker.io gcc g++ make
gpasswd -a ci docker
systemctl start docker

# set-up ci stuff
su ci
cd

# set-up docker-worker things
mkdir hello-world-aarch64 && cd hello-world-aarch64
echo "FROM aarch64/hello-world" > Dockerfile
docker build -t taskcluster/livelog:v4 .
cd ..

# build 0.12.8 from source
wget https://franziskuskiefer.de/data/node012.zip
unzip node012.zip
cd node-v0.12.8
make -j100
exit && cd /home/ci/node-v0.12.8 && make install
su ci && cd /home/ci

