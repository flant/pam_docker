setup() {
  load common
  load fixture
}

test_hostname_equal() {
  [ "$1" == $(hostname) ]
}

test_hostname_not_equal() {
  [ "$1" != $(hostname) ]
}

@test "hostname isolation" {
  test_cmd user5 hostname test_hostname_equal
  for user in ${JAILED_USERS[@]} ; do
    test_cmd $user hostname test_hostname_not_equal
  done
}
