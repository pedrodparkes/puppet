# puppet5::agent::config class
# 
# This class is used to configure the Puppet 5 agent
# 
# @example Declaring the class
#   include puppet5::config
#
# NOTE: Spaces are stripped from paths when they substituted into puppet.conf
#       What kind of monster uses spaces in paths?
#       
# @param [String] ensure If set to 'present' puppet.conf is deployed, if 'absent' it is removed. Default 'installed'
# @param [String] server Sets the FQDN of a puppet server or puppet master. Default is undefined.
# @param [String] environment  Sets the puppet environment. Default is undefined.
# @param [String] runinterval Sets how often the puppet agent runs. By default the puppet agent will run every 30m
# @param [Array[String]] basemodulepaths An array of paths used to set the basemoduelpath setting that lists the directories where puppet checks for modules.

class puppet5::agent::config(
  Variant[Boolean, Enum['present', 'absent']] $ensure = 'present',
  Array[String] $basemodulepaths = [],
  String $server      = '',
  String $environment = '',
  String $runinterval = ''
) {

  include puppet5::oscheck

  case $ensure {
    true, 'present': {
      $ensure_file    = 'file'
    }
    default: {
      $ensure_file    = 'absent'
    }
  }

  $path_string_format = {
    Array => {
      format         => '% a',
      separator      => ':',
      string_formats => {
        String => '%s'
      }
    }
  }

  # Turn the array of basemodulepaths to a basemodulepath string
  # basemodule path is used in the puppet.conf template
  if $basemodulepaths != [] {
    $basemodulepath = String($basemodulepaths, $path_string_format)
  } else {
    # Just making this explicit
    $basemodulepath = undef
  }

  file{'puppet.conf':
    ensure  => $ensure_file,
    path    => lookup('puppet5::files.puppetconf.path', String, 'first'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('puppet5/puppet.conf.erb')
  }

}