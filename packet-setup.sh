#!/bin/bash

# create ci user and home
mkdir /home/ci
useradd -d /home/ci ci
chown -R ci:ci /home/ci

# update and set-up docker
apt-get update
apt-get upgrade -y
apt-get install -y --no-install-recommends docker.io gcc g++ make unzip git
gpasswd -a ci docker
systemctl start docker

# make docker-worker work later
touch /etc/docker-worker-priv.pem

# set-up ci stuff
su -c "./setup-ci.sh 1" -s /bin/bash ci

# install nodejs
cd /home/ci/node && make install

su -c "./setup-ci.sh 2" -s /bin/bash ci

