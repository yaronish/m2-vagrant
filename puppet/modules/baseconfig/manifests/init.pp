# == Class: baseconfig
#
# Performs initial configuration tasks for all Vagrant boxes.
#
class baseconfig {
    host { 'hostmachine':
        ip => '192.168.0.1';
    }

    file { 'bash-profile':
        ensure => file,
        path => "/home/${user}/.bashrc",
        owner  => $user,
        group  => $user,
        mode   => '0644',
        content => template('baseconfig/bashrc.erb')
    }
}
