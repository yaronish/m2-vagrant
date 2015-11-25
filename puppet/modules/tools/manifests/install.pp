# == Define: install
#
# Install cli tool in /vagrant directory
#
define tools::install() {
  file { "/home/vagrant/${name}":
    source  => "puppet:///modules/tools/${name}",
    mode => '0755';
  }
}