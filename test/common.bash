test_su() {
  su $1 -c "$2"
}

test_sudo() {
  sudo -u $1 bash -c "$2"
}

test_ssh() {
  sshpass -p $PASSWORD ssh -o 'StrictHostKeyChecking no' $1@localhost "$2"
}

test_cmd() {
  test_func=$3

  if [ -z "$test_func" ] ; then
    test_su $1 "$2"
    test_sudo $1 "$2"
    test_ssh $1 "$2"
  else
    eval $test_func $(test_su $1 "$2")
    eval $test_func $(test_sudo $1 "$2")
    eval $test_func $(test_ssh $1 "$2")
  fi
}
