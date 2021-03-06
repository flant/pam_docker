JAILED_USERS=( user1 user2 user3 user4 )
PASSWORD="bbfa1c5c-3ae6-4783-a0dc-2118190c62ed"

up_container() {
  name=$1

  if [ -z "$(docker ps | grep $name)" ] ; then
    if [ "$(docker ps -a | grep $name)" != "" ] ; then
      docker rm $name
    fi
    mkdir -p -m 0777 /var/run/shared_dir/
    docker run -d \
      --volume /var/run/shared_dir:/var/run/shared_dir \
      --restart=always --name=$name $DOCKER_TEST_IMAGE /bin/bash -c \
      "echo -n $name > /proc/\$\$/comm && \
       echo $name > /docker_container_name && \
       while true; do date; sleep 1; done"
  fi
}

add_group() {
  name=$1
  groupadd -f $name
}

add_container_group() {
  name=$1
  container=$2
  gid=$(getent group $name | cut -d':' -f3)
  docker exec $container /bin/bash -c "groupadd -f $name -g $gid"
}

add_user() {
  name=$1
  group=$2
  [ -z "$(grep $name /etc/passwd)" ] && useradd $name -g $group || true
}

add_container_user() {
  name=$1
  container=$2
  uid=$(getent passwd $name | cut -d':' -f3)
  gid=$(getent passwd $name | cut -d':' -f4)
  ( docker exec $container /bin/bash -c \
    "[ -z \"\$(grep $name /etc/passwd)\" ] && useradd -m $name -u $uid -g $gid"
  ) || true
}

set_user_container() {
  name=$1
  container=$2
  line="$name $container"

  touch /etc/security/docker.conf
  ( [ -z "$(grep "$line" /etc/security/docker.conf)" ] &&
    echo $line >> /etc/security/docker.conf
  ) || true
}

set_group_container() {
  name=$1
  container=$2
  line="@$name $container"

  touch /etc/security/docker.conf
  ( [ -z "$(grep "$line" /etc/security/docker.conf)" ] &&
    echo $line >> /etc/security/docker.conf
  ) || true
}

set_user_password() {
  name=$1
  password=$2
  echo -e "$password\n$password" | passwd $name
}

setup_test_mount() {
  mkdir -p /tmp/mount_test_dir1 /tmp/mount_test_dir2
  ( [ -z "$(mount | grep mount_test_dir)" ] &&
    mount --bind /tmp/mount_test_dir1 /tmp/mount_test_dir2
  ) || true
}

up_container container1
up_container container2
up_container container3

add_group group1
add_container_group group1 container1
add_container_group group1 container3

add_group group2
add_container_group group2 container2

add_user user1 group1
add_container_user user1 container1
add_container_user user1 container3

add_user user2 group1
add_container_user user2 container1

add_user user3 group2
add_container_user user3 container2

add_user user4 group2
add_container_user user4 container2

add_user user5 group2

set_user_container user1 container3
set_user_container user3 container2
set_user_container user4 container2
set_group_container group1 container1

set_user_password user1 $PASSWORD
set_user_password user2 $PASSWORD
set_user_password user3 $PASSWORD
set_user_password user4 $PASSWORD
set_user_password user5 $PASSWORD

setup_test_mount
