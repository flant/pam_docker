TEST_BACKGROUND_PROCESS_NAME=tnt
TEST_BACKGROUND_PROCESS="echo -n $TEST_BACKGROUND_PROCESS_NAME > /proc/\$\$/comm ; \
                         echo \$\$ > /var/run/shared_dir/$TEST_BACKGROUND_PROCESS_NAME ; \
                         while true ; do sleep 1 ; done 1>&- 2>&- <&-"

background_process_pid() {
  process_name=$1
  COUNTER=0 && (while ! [ -f /var/run/shared_dir/$process_name ] ; do
                  if [ $COUNTER -ge 20 ] ; then
                    echo "Unable to get background process pid" 1>&2 ;
                    return 1 ;
                  fi ;
                  sleep 1 ;
                  let COUNTER=COUNTER+1 ;
                done)
  ps -A | grep $process_name | sed -r 's/^\s+//' | cut -d' ' -f1
}

background_process_kill() {
  process_name=$1
  pid=$(background_process_pid $process_name)

  kill $pid
  rm -f /var/run/shared_dir/$process_name
}
