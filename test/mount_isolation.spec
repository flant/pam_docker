setup() {
  load common
  load fixture
}

@test "mount isolation" {
  test_cmd user5 '[ "$(mount | grep testdir)" != "" ]'
  for user in ${JAILED_USERS[@]} ; do
    test_cmd $user '[ -z "$(mount | grep testdir)" ]'
  done
}

