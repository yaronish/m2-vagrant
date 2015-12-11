if $hostname == undef {
    $hostname = "magetwo.vg"
}
if $user == undef {
    $user = "vagrant"
}
if $group == undef {
    $group = "vagrant"
}

Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin", "/home/${user}/.composer/vendor/bin/" ] }

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
    extrarepo => 'epel remi_php56 mysql_community remi',
    update => true,
    before => Package['java-1.8.0-openjdk'],
    stage => 'main'
}
->
class { '::mysql::server':
    package_name => 'mysql-community-server',
    override_options => {'mysqld' => {'bind-address' => '0.0.0.0'}},
    stage => 'main'
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
                'max_nesting_level' => 300
            }
        }
    },
    settings => {
        'always_populate_raw_post_data' => -1,
        'date.timezone' => 'UTC',
        'session.save_path' => '/tmp',
        'memory_limit' => '2G'
    },
    stage => 'main'
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

apache::vhost { 'magetwo.vg':
    priority => '10',
    docroot => "/var/www/html/${hostname}",
    docroot_owner => $user,
    docroot_group => $group,
    docroot_create => true,
    server_name => $hostname,
    directory => "/var/www/html/${hostname}",
    directory_allow_override => 'All',
    directory_options => 'FollowSymLinks Multiviews',
    require => Package['httpd'],
    template => 'custom/virtualhost/vhost-cgi.conf.erb',
    env_variables => ['PHP_IDE_CONFIG serverName=magentovm', 'XDEBUG_CONFIG idekey=PHPSTORM'],
}

include baseconfig, tools, yum, apache, php


package {'git': ensure => present}


###APACHE customization
exec { 'httpd-docroot-chown':
    command => "chown -R ${user}.${group} /var/www/html",
    user => root,
    group => root,
    require => Package['apache'],
    notify => Service['httpd']
}
->
file_line { 'replace apache user':
    path => "/etc/httpd/conf/httpd.conf",
    line => "User ${user}",
    match => "User apache"
}
->
file_line { 'replace apache group':
    path => "/etc/httpd/conf/httpd.conf",
    line => "Group ${group}",
    match => "Group apache"
}

###MYSQL customization
exec {'mysql-grant-local-user':
    command => 'mysql -uroot -e "grant all privileges on *.* to \'magento\'@\'localhost\' identified by \'123123q\' with grant option;"',
    require => [Package['mysql-community-server']]
}
->
exec {'mysql-grant-remote-user':
    command => 'mysql -uroot -e "grant all privileges on *.* to \'magento_remote\'@\'%\' identified by \'123123q\' with grant option;"',
    require => [Package['mysql-community-server']]
}
->
exec {'mysql-flush-privileges':
    command => "mysql -uroot -e'flush privileges;'",
    require => [Package['mysql-community-server']]
}

###COMPOSER settings

exec { 'composer-chown':
    command => "chown ${user}.${group} /usr/local/bin/composer",
    require => File['/usr/local/bin/composer']
}

exec { 'composer-chmod':
    command => 'chmod 777 /usr/local/bin/composer',
    require => File['/usr/local/bin/composer']
}

exec { 'composer-update':
    command => 'composer self-update',
    environment => ["HOME=/home/${user}"],
    user => $user,
    require => [Exec['composer-chmod'], Exec['composer-chown']]
}

exec { 'phpcpd':
    command => 'composer global require --dev "sebastian/phpcpd=*"',
    environment => ["COMPOSER_HOME=/home/${user}/.composer"],
    cwd => "/home/${user}/.composer",
    user => $user,
    group => $group,
    require => Exec['composer-update'],
}

exec { 'phpunit':
    command => 'composer global require --dev "phpunit/phpunit=4.4.*"',
    environment => ["COMPOSER_HOME=/home/${user}/.composer"],
    cwd => "/home/${user}/.composer",
    user => $user,
    group => $group,
    require => Exec['composer-update']
}

###SYSTEM tunning
file { 'security/limits.d/90-nproc.conf':
    path => '/etc/security/limits.d/90-nproc.conf',
    ensure => false
}

service { 'iptables':
    enable => false,
    ensure => false
}

#REQUIRED for functional tests
package {'java-1.8.0-openjdk':
    ensure => true
}

package { 'xorg-x11-server-Xvfb':
    ensure => true
}

package { 'firefox':
    ensure => true
}

exec { 'get-selenium':
    command => "wget http://selenium-release.storage.googleapis.com/2.48/selenium-server-standalone-2.48.2.jar -O /${user}/selenium-server-2.48.jar",
    require => Package['java-1.8.0-openjdk']
}
