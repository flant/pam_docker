JAILED_USERS=(molotok zubilo vodka ogurchik)

setup_mount_isolation() {
  mkdir -p /tmp/testdir1 /tmp/testdir2
  mount --bind /tmp/testdir1 /tmp/testdir2
}

teardown_mount_isolation() {
  umount /tmp/testdir2
  rm -rf /tmp/testdir1 /tmp/testdir2
}

setup_process_isolation() {
  bash -c 'echo -n "testprocess" > /proc/$$/comm ; while true; do sleep 1; done' &
  export PROCESS_ISOLATION_PID=$!
}

teardown_process_isolation() {
  kill -9 $PROCESS_ISOLATION_PID
}

setup() {
  setup_mount_isolation
  setup_process_isolation
}

teardown() {
  teardown_mount_isolation
  teardown_process_isolation
}

test_su() {
  su $1 -c "$2"
}

test_sudo() {
  sudo -u $1 bash -c "$2"
}

test_ssh() {
  sshpass -p qwerty ssh -o "StrictHostKeyChecking no" $1@localhost "$2"
}

test_cmd() {
  test_su $1 "$2"
  test_sudo $1 "$2"
  test_ssh $1 "$2"
}

@test "mount and process isolation" {
  test_cmd fonarik '[ "$(mount | grep testdir)" != "" ]'
  test_cmd fonarik '[ "$(ps -A | grep testprocess)" != "" ]'

  for user in ${JAILED_USERS[@]}
  do
    test_cmd $user '[ -z $(mount | grep testdir2) ]'
    test_cmd $user '[ -z $(ps -A | grep testprocess) ]'
  done
}
