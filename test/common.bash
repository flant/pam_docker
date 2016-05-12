test_su() {
  su $1 -c '$2'
}

test_sudo() {
  sudo -u $1 bash -c '$2'
}

test_ssh() {
  sshpass -p $PASSWORD ssh -o 'StrictHostKeyChecking no' $1@localhost '$2'
}

test_cmd() {
  test_su $1 '$2'
  test_sudo $1 '$2'
  test_ssh $1 '$2'
}
