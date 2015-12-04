Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin" ] }

stage { 'pre':
    before => Stage['main']
}

class { 'baseconfig':
    stage => 'pre'
}

File {
    owner => 'root',
    group => 'root',
    mode  => '0644',
}

class { 'yum':
    extrarepo => 'epel remi_php56 mysql_community',
    update => true,
}
->
class { '::mysql::server':
    package_name => 'mysql-community-server',
    override_options => {'mysqld' => {'bind-address' => '0.0.0.0'}}
}
->
class { 'php':
    package_prefix => 'php-',
    manage_repos => true,
    extensions => {
        'mcrypt' => {},
        'bcmath' => {},
        'intl' => {},
        'gd' => {},
        'mbstring' => {},
        'pdo' => {},
        'mysql' => {},
        'soap' => {},
        'pecl-xdebug' => {
            'settings_prefix' => 'xdebug',
            'settings' => {
                'remote_enable' => 1,
                'remote_host' => 'hostmachine',
                'idekey' => 'PHPSTORM',
                'max_nesting_level' => 200
            }
        }
    },
    settings => {
        'always_populate_raw_post_data' => -1,
        'date.timezone' => 'UTC',
        'session.save_path' => '/tmp',
        'memory_limit' => '2G'
    }
}

mysql::db { 'magento':
    user => 'root',
    password => '',
    host => 'localhost',
    grant => 'ALL',
    require => [Package['mysql-community-server']]
}

mysql::db { 'magento_integration_tests':
    user => 'root',
    password => '',
    host => 'localhost',
    grant => 'ALL',
    require => [Package['mysql-community-server']]
}

exec {'mysql-grant-local-user':
    path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
    command => 'mysql -uroot -e "grant all privileges on *.* to \'magento\'@\'localhost\' identified by \'123123q\' with grant option;"',
    require => [Package['mysql-community-server']]
}
->
exec {'mysql-grant-remote-user':
    path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
    command => 'mysql -uroot -e "grant all privileges on *.* to \'magento_remote\'@\'%\' identified by \'123123q\' with grant option;"',
    require => [Package['mysql-community-server']]
}
->
exec {'mysql-flush-privileges':
    path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
    command => "mysql -uroot -e'flush privileges;'",
    require => [Package['mysql-community-server']]
}

class {'apache':
    process_user => 'vagrant'
}

apache::vhost { 'magetwo.vg':
    priority => '10',
    docroot => '/var/www/html/magetwo.vg',
    docroot_owner => 'vagrant',
    docroot_group => 'vagrant',
    docroot_create => true,
    server_name => 'magetwo.vg',
    directory => '/var/www/html/magetwo.vg',
    directory_allow_override => 'All',
    directory_options => 'FollowSymLinks Multiviews',
    require => Package['httpd'],
    template => 'custom/virtualhost/vhost-cgi.conf.erb',
    env_variables => ['PHP_IDE_CONFIG serverName=magetwo.vg', 'XDEBUG_CONFIG idekey=PHPSTORM'],
}

include baseconfig, tools, yum, apache, php

service { 'iptables':
    enable => false,
    ensure => false
}

package {'git': ensure => present}

file { 'security/limits.d/90-nproc.conf':
    path => '/etc/security/limits.d/90-nproc.conf',
    ensure => false
}

exec { 'composer-chown':
    command => 'chown vagrant.vagrant /usr/local/bin/composer',
    require => File['/usr/local/bin/composer']
}

exec { 'httpd-docroot-chown':
    command => 'chown vagrant.vagrant /var/www/html',
    require => Package['apache']
}

exec { 'composer-chmod':
    command => 'chmod 777 /usr/local/bin/composer',
    require => File['/usr/local/bin/composer']
}

exec { 'composer-update':
    command => 'composer self-update',
    environment => ['HOME=/home/vagrant'],
    path    => '/usr/bin:/usr/local/bin:/home/vagrant/.composer/vendor/bin/',
    user => 'vagrant',
    require => [Exec['composer-chmod'], Exec['composer-chown']]
}

exec { 'phpcpd':
    command => 'composer global require --dev "sebastian/phpcpd=*"',
    environment => ['COMPOSER_HOME=/home/vagrant/.composer'],
    cwd => '/home/vagrant/.composer',
    path    => '/usr/bin:/usr/local/bin:/home/vagrant/.composer/vendor/bin/',
    user => 'vagrant',
    group => 'vagrant',
    require => Exec['composer-update'],
}

exec { 'phpunit':
    command => 'composer global require --dev "phpunit/phpunit=4.4.*"',
    environment => ['COMPOSER_HOME=/home/vagrant/.composer'],
    cwd => '/home/vagrant/.composer',
    path    => '/usr/bin:/usr/local/bin:/home/vagrant/.composer/vendor/bin/',
    user => 'vagrant',
    group => 'vagrant',
    require => Exec['composer-update']
}
