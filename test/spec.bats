setup() {
  load common
  load fixture
}

@test "mount and process isolation" {
  test_cmd user5 '[ "$(mount | grep testdir)" != "" ]'
#test_cmd user5 '[ "$(ps -A | grep testprocess)" != "" ]'

  for user in ${JAILED_USERS[@]}
  do
    test_cmd $user '[ -z "$(mount | grep testdir)" ]'
#test_cmd $user '[ -z "$(ps -A | grep testprocess)" ]'
  done
}
