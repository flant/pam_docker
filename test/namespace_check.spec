setup() {
  load common
  load fixture
  load background_process
}

do_check_process_namespace() {
  process_name=$1
  user=$2
  check_pid=$3
  pid=$(background_process_pid $process_name)

  # TODO net namespace isolation not working

  namespace_entries_list=$(cat \
    <(for ns in $(ls -1 /proc/$pid/ns/) ; do readlink /proc/$pid/ns/$ns ; done) \
    <(for ns in $(ls -1 /proc/$check_pid/ns/) ; do readlink /proc/$check_pid/ns/$ns ; done) \
    | sort | uniq -c | sed -r 's/^\s+//')

  background_process_kill $process_name

  echo "$namespace_entries_list"
  [ -z "$(echo "$namespace_entries_list" | grep -v '^2')" ]
}

check_non_container_process_namespace() {
  process_name=$1
  user=$2
  do_check_process_namespace $process_name $user 1
}

check_container_process_namespace() {
  process_name=$1
  user=$2
  do_check_process_namespace $process_name $user $(user_container_pid $user)
}

@test "namespace check" {
  background=yes \
    test_cmd user5 "$TEST_BACKGROUND_PROCESS" \
             check_non_container_process_namespace \
             $TEST_BACKGROUND_PROCESS_NAME user5

  for user in ${JAILED_USERS[@]} ; do
    background=yes \
      test_cmd $user "$TEST_BACKGROUND_PROCESS" \
               check_container_process_namespace \
               $TEST_BACKGROUND_PROCESS_NAME $user
  done
}
