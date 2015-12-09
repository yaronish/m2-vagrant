#!/usr/bin/env bash
echo "Adding puppet repo"
sudo rpm -ivh https://yum.puppetlabs.com/el/6/products/x86_64/puppetlabs-release-6-7.noarch.rpm
echo "installing puppet"
sudo yum install puppet -y
echo "ensure puppet service is running"
sudo puppet resource service puppet ensure=running enable=true
#echo "ensure puppet service is running"
#sudo puppet resource service puppetmaster ensure=running enable=true

#echo "ensure puppet service is running for standalone install"
#sudo puppet resource cron puppet-apply ensure=present user=root minute=30 command='/usr/bin/puppet apply $(puppet apply --configprint manifest)'
