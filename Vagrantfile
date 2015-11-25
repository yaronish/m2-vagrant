# -*- mode: ruby -*-
# vi: set ft=ruby :

box      = 'puppetlabs/centos-6.6-64-puppet'
#box      = 'bento/centos-6.7'
hostname = 'magetwo'
domain   = 'vg'
ip       = '192.168.0.200'
ram      = '3000'

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.trigger.before :up do
    info "Clonning git repos..."
    run  "bash ./get-libs.sh"
  end

  config.vm.box = box
  config.vm.box_check_update = false
  config.vm.hostname = hostname + '.' + domain
  config.vm.network "private_network", ip: ip

  config.vm.box_version = '1.0.1'
  config.vm.provider "virtualbox" do |v|
    v.customize ['modifyvm', :id, '--name', hostname, '--memory', ram]
  end

  config.vm.synced_folder "../../html", "/var/www/html", type: "nfs"

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = 'puppet/manifests'
    puppet.manifest_file = 'site.pp'
    puppet.module_path = 'puppet/modules'
    puppet.facter = {
        'hostname' => hostname + '.' + domain
    }
  end

end