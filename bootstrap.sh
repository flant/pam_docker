#!/usr/bin/env /bin/bash

apt-get update
apt-get install -y build-essential libpam0g-dev apt-transport-https ca-certificates
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo 'deb https://apt.dockerproject.org/repo ubuntu-trusty main' > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y docker-engine

cd /vagrant
make clean
make
make install-ubuntu-14.04

docker run -d --name=container1 ubuntu:14.04 /bin/bash -c 'while true; do date; sleep 1; done'
docker run -d --name=container2 ubuntu:14.04 /bin/bash -c 'while true; do date; sleep 1; done'
docker run -d --name=container3 ubuntu:14.04 /bin/bash -c 'while true; do date; sleep 1; done'

groupadd myusers1
docker exec container1 /bin/bash -c "groupadd myusers1 -g $(getent group myusers1 | cut -d':' -f3)"
docker exec container2 /bin/bash -c "groupadd myusers1 -g $(getent group myusers1 | cut -d':' -f3)"

groupadd myusers2
docker exec container3 /bin/bash -c "groupadd myusers2 -g $(getent group myusers2 | cut -d':' -f3)"

useradd myuser1 -g myusers1
docker exec container1 /bin/bash -c "useradd -m myuser1 -u $(getent passwd myuser1 | cut -d':' -f3) -g myusers1"

useradd myuser2 -g myusers1
docker exec container2 /bin/bash -c "useradd -m myuser2 -u $(getent passwd myuser2 | cut -d':' -f3) -g myusers1"

useradd myuser3 -g myusers2
docker exec container3 /bin/bash -c "useradd -m myuser3 -u $(getent passwd myuser3 | cut -d':' -f3) -g myusers2"

echo 'myuser1 container1' >> /etc/security/docker.conf
echo 'myuser2 container2' >> /etc/security/docker.conf
echo '@myusers2 container3' >> /etc/security/docker.conf

echo '* * * * * echo "$(date) Get me outta here! I am $(id)" >> ~/HELP' | crontab -u myuser1 -
echo '* * * * * echo "$(date) Get me outta here! I am $(id)" >> ~/HELP' | crontab -u myuser2 -
echo '* * * * * echo "$(date) Get me outta here! I am $(id)" >> ~/HELP' | crontab -u myuser3 -
