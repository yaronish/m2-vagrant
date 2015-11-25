# == Class: baseconfig
#
# Performs initial configuration tasks for all Vagrant boxes.
#
class tools {
  tools::install {['magento']: }
}
