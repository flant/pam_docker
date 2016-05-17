setup() {
  load common
  load fixture

  bash -c 'echo $$ > /var/run/testprocess.pid ; \
           echo -n testprocess > /proc/self/comm ; \
           while true ; do sleep 1 ; done' > /dev/null 2>&1 &
}

teardown() {
  kill $(cat /var/run/testprocess.pid)
}

@test "process isolation" {
  test_cmd user5 '[ "$(ps -A | grep testprocess)" != "" ]'
  for user in ${JAILED_USERS[@]} ; do
    test_cmd $user '[ -z "$(ps -A | grep testprocess)" ]'
  done
}
