# -*- mode: ruby -*-
# vi: set ft=ruby :
# vi: set sts=2 ts=2 sw=2 :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.provision :shell, path: "provision/bootstrap.sh"

  branch = %x{git rev-parse --abbrev-ref HEAD}.strip
  if branch == 'packagefile'
    config.vm.provision :shell, path: "provision/thepackager.sh"
  end
end
