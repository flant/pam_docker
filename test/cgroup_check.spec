setup() {
  load common
  load fixture
  load background_process
}

do_check_process_cgroup() {
  process_name=$1
  user=$2
  check_pid=$3

  pid=$(background_process_pid $process_name)

  echo pid=$pid

  check_cgroup_list=$(cat /proc/$pid/cgroup /proc/$check_pid/cgroup | sort | uniq -c | sed -r 's/^\s+//')

  background_process_kill $process_name

  [ -z "$(echo "$check_cgroup_list" | grep -v '^2')" ]
}

check_non_container_process_cgroup() {
  do_check_process_cgroup $1 $2 1
}

check_container_process_cgroup() {
  container_name=$(su $user -c 'cat /docker_container_name')
  container_pid=$(ps -A | grep $container_name | sed -r 's/^\s+//' | cut -d' ' -f1)

  do_check_process_cgroup $1 $2 $container_pid
}

@test "cgroup check" {
  background=yes \
    test_cmd user5 "$TEST_BACKGROUND_PROCESS" \
             check_non_container_process_cgroup \
             $TEST_BACKGROUND_PROCESS_NAME user5

  for user in ${JAILED_USERS[@]} ; do
    background=yes \
      test_cmd $user "$TEST_BACKGROUND_PROCESS" \
               check_container_process_cgroup \
               $TEST_BACKGROUND_PROCESS_NAME $user
  done
}
