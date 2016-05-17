setup() {
  load common
  load fixture
}

@test "filesystem isolation" {
  test_cmd user5 '! (cat /docker_container_name >/dev/null 2>&1)'
  for user in ${JAILED_USERS[@]} ; do
    test_cmd $user 'cat /docker_container_name'
  done
}
