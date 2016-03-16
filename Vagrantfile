# -*- mode: ruby -*-
# vi: set ft=ruby :
# vi: set sts=2 ts=2 sw=2 :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.provision :shell, path: "provision/bootstrap.sh"
  config.vm.synced_folder '.', '/vagrant', group: :root, owner: :root

  branch = %x{git rev-parse --abbrev-ref HEAD}.strip
  if branch == 'packagefile'
    config.vm.provision :shell, path: "provision/buildizer.sh"
  end
end
