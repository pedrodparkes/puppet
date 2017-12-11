node 'puppetmaster.usgroup.dev' {
  class{'puppetdb':}
  class{'puppetdb::master::config':}
  class{'apache':
    default_vhost=>false,
  }
  class{'apache::mod::wsgi':}
  class{'puppetboard':
    manage_git=>true,
    manage_virtualenv=>true,
    enable_catalog=>true,
  }
  class{'puppetboard::apache::vhost':
    vhost_name=>'puppetmaster',
    port=>80,
    ssl=>false,
  }
}