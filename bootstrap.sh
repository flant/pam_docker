#!/usr/bin/env /bin/bash

apt-get update
apt-get install -y build-essential libpam0g-dev

cd /vagrant
make clean
make
make install-ubuntu-14.04
