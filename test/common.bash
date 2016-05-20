run_su() {
  su $1 -c "$2"
}

run_sudo() {
  sudo -u $1 bash -c "$2"
}

run_ssh() {
  sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no $1@localhost "$2"
}

test_run() {
  if [ -z "$test_func" ] ; then
    eval $run_func $run_func_args
  elif [ -z "$background" ] ; then
    eval $test_func $(eval $run_func $run_func_args) $test_func_args
  else
    eval $run_func $run_func_args &
    eval $test_func $test_func_args
  fi
}

test_cmd() {
  user=$1
  cmd=$2
  if [ "$3" != "" ] ; then
    test_func=$3
    shift 3
    test_func_args=$@
  fi

  for run_func in run_su run_sudo run_ssh ; do
    background=$background \
      run_func=$run_func run_func_args="$user '$cmd'" \
        test_func=$test_func test_func_args=$test_func_args \
          test_run
  done
}
