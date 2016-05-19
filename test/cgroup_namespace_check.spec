setup() {
  load common
  load fixture
}

check_process_cgroup() {
  process_name=$1
  user=$2
  container=$(su $user -c 'cat /docker_container_name')
  pid=$(ps -A | grep $process_name | sed -r 's/^\s+//' | cut -d' ' -f1)

  echo "[$process_name - $user - $container - $pid]"

  kill $pid
}

@test "cgroup check" {
  background=yes test_cmd user1 'echo -n tnt > /proc/$$/comm ; while true ; do sleep 1 ; done &' check_process_cgroup tnt user1
}
