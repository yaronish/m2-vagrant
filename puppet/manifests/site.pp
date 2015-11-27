Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

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
        'intl' => {},
        'gd' => {},
        'mbstring' => {},
        'pdo' => {},
        'mysql' => {},
        'pecl-xdebug' => {
            'settings_prefix' => 'xdebug',
            'settings' => {
                'remote_enable' => 1,
                'remote_host' => 'hostmachine',
                'idekey' => 'PHPSTORM'
            }
        }
    },
    settings => {
        'always_populate_raw_post_data' => -1,
        'date.timezone' => 'UTC',
        'session.save_path' => '/tmp'
    }
}


mysql::db { 'magento':
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

apache::vhost { 'magetwo.vg':
    docroot => '/var/www/html/magetwo.vg',
    server_name => 'magetwo.vg',
    directory => '/var/www/html/magetwo.vg',
    directory_allow_override => 'All',
    directory_options => 'FollowSymLinks Multiviews',
    require => Package['httpd'],
    template => 'custom/virtualhost/vhost-cgi.conf.erb',
    env_variables => ['PHP_IDE_CONFIG serverName=magetwo.vg', 'XDEBUG_CONFIG idekey=PHPSTORM']
}

include baseconfig, tools, yum, apache, php

service { 'iptables':
    enable => false,
    ensure => false
}

package {'git': ensure => present}
