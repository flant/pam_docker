#!/bin/bash

curl -sSL https://rvm.io/mpapis.asc | sudo gpg --import -
curl -sSL https://get.rvm.io | sudo bash -s stable
source /etc/profile.d/rvm.sh

echo 'source /etc/profile.d/rvm.sh' >> /etc/bash.bashrc
echo 'export BUNDLE_GEMFILE=/vagrant/buildizer/Gemfile' >> /etc/bash.bashrc
sed -ir 's/# *(\".*history-search)/\1/' /etc/inputrc

rvm group add rvm vagrant
rvm install 2.2.1 --quiet-curl
rvm --default use 2.2.1
gem install bundler

cd /vagrant/buildizer
bundle install
