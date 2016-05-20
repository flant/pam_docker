setup() {
  load common
  load fixture
}

do_check_processs_cgroup() {
  process_name=$1
  user=$2
  check_pid=$3

  COUNTER=0 && (while ! [ -f /var/run/shared_dir/$process_name ] ; do
                  if [ $COUNTER -ge 20 ] ; then
                    echo "Unable to start background process" 1>&2 ;
                    return 1 ;
                  fi ;
                  sleep 1 ;
                  let COUNTER=COUNTER+1 ;
                done)
  pid=$(ps -A | grep $process_name | sed -r 's/^\s+//' | cut -d' ' -f1)

  check_cgroup_list=$(cat /proc/$pid/cgroup /proc/$check_pid/cgroup | sort | uniq -c | sed -r 's/^\s+//')

  kill $pid
  rm -f /var/run/shared_dir/$process_name

  [ -z "$(echo "$check_cgroup_list" | grep -v '^2')" ]
}

check_non_container_process_cgroup() {
  do_check_processs_cgroup $1 $2 1
}

check_container_process_cgroup() {
  container_name=$(su $user -c 'cat /docker_container_name')
  container_pid=$(ps -A | grep $container_name | sed -r 's/^\s+//' | cut -d' ' -f1)

  do_check_processs_cgroup $1 $2 $container_pid
}

@test "cgroup check" {
  background=yes \
    test_cmd user5 \
      'echo -n tnt > /proc/$$/comm ; echo $$ > /var/run/shared_dir/tnt ; while true ; do sleep 1 ; done 1>&- 2>&- <&-' \
        check_non_container_process_cgroup tnt user5

  for user in ${JAILED_USERS[@]} ; do
    background=yes \
      test_cmd $user \
        'echo -n tnt > /proc/$$/comm ; echo $$ > /var/run/shared_dir/tnt ; while true ; do sleep 1 ; done 1>&- 2>&- <&-' \
          check_container_process_cgroup tnt $user
  done
}
