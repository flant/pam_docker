setup() {
  load common
  load fixture
}

@test "process isolation" {
  test_cmd user5 '[ "$(ps -A | grep testprocess)" != "" ]'
  for user in ${JAILED_USERS[@]} ; do
    test_cmd $user '[ -z "$(ps -A | grep testprocess)" ]'
  done
}
