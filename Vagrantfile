# -*- mode: ruby -*-
# vi: set ft=ruby :

hostname = 'magetwo.vg'
user     = 'vagrant'
group    = 'vagrant'

ip       = '192.168.0.200'
ram      = '4096'
box      = 'puppetlabs/centos-6.6-64-puppet'

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.trigger.before :up do
    run  "bash ./get-libs.sh"
  end
  config.ssh.forward_x11 = true
  config.vm.box = box
  config.vm.box_check_update = false
  config.vm.hostname = hostname
  config.vm.network "private_network", ip: ip

  config.vm.box_version = '1.0.1'
  config.vm.provider "virtualbox" do |v|
    v.customize ['modifyvm', :id, '--name', hostname, '--memory', ram]
  end

  config.vm.synced_folder "../", "/vagrant", type: "nfs"

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = 'puppet/manifests'
    puppet.manifest_file = 'site.pp'
    puppet.module_path = 'puppet/modules'
    puppet.facter = {
        'hostname' => hostname,
        'user' => user,
        'group' => group
    }
  end

end
