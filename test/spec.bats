setup() {
#source test/common.sh
  load fixture
}

@test "mount and process isolation" {
#test_cmd fonarik '[ "$(mount | grep testdir)" != "" ]'
#test_cmd fonarik '[ "$(ps -A | grep testprocess)" != "" ]'
#
#for user in ${JAILED_USERS[@]}
#do
#test_cmd $user '[ -z "$(mount | grep testdir2)" ]'
#test_cmd $user '[ -z "$(ps -A | grep testprocess)" ]'
#done
  echo
}
