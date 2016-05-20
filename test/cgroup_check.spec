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

  cgroup_entries_list=$(cat /proc/$pid/cgroup /proc/$check_pid/cgroup | sort | uniq -c | sed -r 's/^\s+//')

  background_process_kill $process_name

  [ -z "$(echo "$cgroup_entries_list" | grep -v '^2')" ]
}

check_non_container_process_cgroup() {
  process_name=$1
  user=$2
  do_check_process_cgroup $process_name $user 1
}

check_container_process_cgroup() {
  process_name=$1
  user=$2
  do_check_process_cgroup $process_name $user $(user_container_pid $user)
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
