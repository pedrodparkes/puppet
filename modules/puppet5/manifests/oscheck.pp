# puppet5::oscheck class
# 
# This class is used to check the puppet5 module is running on a supported OS
# 
# @example Declaring the class
#   include puppet::oscheck
#   
# This class takes no parameters
#

class puppet5::oscheck {

  # Supported OS check
  case $::osfamily {
    'RedHat':{
      if $::operatingsystemmajrelease in ['7','6'] {
        # Do nothing
      } else {
        fail("The puppet5 module does not support release ${::operatingsystemmajrelease} of ${::osfamily} family of operating systems")
      }
    }
    default:{
      fail("The puppet5 module does not support ${::osfamily} family of operating systems")
    }
  }

}