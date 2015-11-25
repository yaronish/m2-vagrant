#!/usr/bin/env bash
cd ./puppet/modules/
if [ ! -d "apache" ]; then
git clone http://github.com/example42/puppet-apache.git apache
fi

if [ ! -d "puppetlabs-inifile" ]; then
git clone https://github.com/puppetlabs/puppetlabs-inifile.git
fi

if [ ! -d "mysql" ]; then
git clone https://github.com/puppetlabs/puppetlabs-mysql.git mysql
fi

if [ ! -d "php" ]; then
git clone https://github.com/mayflower/puppet-php.git php
fi

if [ ! -d "puppi" ]; then
git clone https://github.com/example42/puppi.git
fi

if [ ! -d "stdlib" ]; then
git clone https://github.com/puppetlabs/puppetlabs-stdlib.git stdlibs
fi

if [ ! -d "yum" ]; then
git clone http://github.com/example42/puppet-yum.git yum
fi

cd ../..
