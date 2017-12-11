# puppet-puppet5

[![experimental](http://badges.github.io/stability-badges/dist/experimental.svg)](http://github.com/badges/stability-badges)
![License](https://img.shields.io/badge/license-Apache%202-blue.svg)

[![Build Status](https://travis-ci.org/Aethylred/puppet-puppet5.svg?branch=master)](https://travis-ci.org/Aethylred/puppet-puppet5)
[![Coverage Status](https://coveralls.io/repos/github/Aethylred/puppet-puppet5/badge.svg?branch=master)](https://coveralls.io/github/Aethylred/puppet-puppet5?branch=master)
[![Dependency Status](https://gemnasium.com/badges/github.com/Aethylred/puppet-puppet5.svg)](https://gemnasium.com/github.com/Aethylred/puppet-puppet5)

[![Puppet Forge Version](http://img.shields.io/puppetforge/v/Aethylred/puppet5.svg)](https://forge.puppet.com/Aethylred/puppet5)
[![Puppet Forge Downloads](http://img.shields.io/puppetforge/dt/Aethylred/puppet5.svg)](https://forge.puppet.com/Aethylred/puppet5)
[![Puppet Forge Endorsement](https://img.shields.io/puppetforge/e/Aethylred/puppet5.svg)](https://forge.puppet.com/Aethylred/puppet5)

# Introduction
A Puppet module to install and manage Puppet v5.x

This module currently installs and configures the following Puppet software and services:
- `puppet-agent`

# Bootstrap

This module is written to run on Puppet 5.x, many operating system disributions do not have this package available in their standard package repostitories. The `bootstrap` directory contains a collection of bash scripts that will add the Puppetlabs Puppet 5 repositories, install the `puppet-agent` package, install Rubygems, and finally install `librarian-puppet`.

These scripts will need to be run as an administrator, and often they require re-logging to update the bash environment and paths after installation.

Once this bootstrap is completed the module and test scripts should all work.

## Bootstrapping Process

1. Login as root
2. Make the directory `/etc/puppetlabs/code/modules`:
3. Clone this repository (or install it from the [Puppet Forge](https://forge.puppet.com/Aethylred/puppet5)) to `/etc/puppetlabs/code/modules/puppet5`:

    ```shell
    $ git clone https://github.com/Aethylred/puppet-puppet5.git /etc/puppetlabs/code/modules/puppet5
    ```

4. Run the bootstrap script appropriate for your OS and distribution:

    ```shell
    $ /etc/puppetlabs/code/modules/puppet5/bootstrap/puppet5_bootstrap_rhel
    ```

5. Relog as root to refresh paths and environment
6. Execute test manifest to verify module:

    ```shell
    $ puppet apply /etc/puppetlabs/code/modules/puppet5/tests/puppet-agent.pp
    ```

## Bootstrap Scripts

| OS | Script |
| --- | --- |
| CentOS 5,6,7 | `puppet5_bootstrap_rhel` |
| RedHat 5,6,7 | `puppet5_bootstrap_rhel` |

# Prerequsites

This module requires the installation of a package repository that provides the Puppet v5.x packages. It includes the `puppet5::repos` class to configure the Puppetlabs repositories, however this class is not explicitly required. Any process that make the packages available via a suitable package provider will do, allowing for the configuration of local mirrors or other alternative repositories for installing Puppet v5.x

It is recommended that the class is installed using the following patterns.

## Using the Puppetlabs Repositories

```puppet
class{'puppet5::repos':
  before => Class['puppet5']
}

include puppet5
```

## Using a Local Repository

```puppet
yumrepo{'local_mirror':
  enabled  => true,
  descr    => "A local mirror of the Puppetlabs Puppet5 Package el ${::operatingsystemmajrelease} repository",
  ...
  before  => Class['puppet5'],
}

include puppet5
```

# Classes

## `puppet5`

This wrapper class can be used to install, configure and manage the `puppet-agent` service using a single class declaration. It wraps the `puppet5::agent::install`, `puppet5::agent::config` and `puppet5::agent::service` classes. All parameters are passed through to the other classes with minimal changes.

### Parameters

#### [String] package

The name of package to be installed. The default is `puppet-agent`

#### [String] version

The version of the package to be installed. The default is provided by Hiera.

#### [String] ensure

Ensure if the package is `installed` or `absent`, the default is `installed`

#### [String] service

If set to `running` the `puppet-agent` service will be enabled and set to run at boot. If it is set to `stopped` the service will be stopped and disabled. The default is `running`

## `puppet5::agent::install`

This class installs the `puppet-agent` package and ensures that all the directories created by the package exist and have the correct ownership and permissions.

### Parameters

#### [String] package

The name of the package to be installed. The default is `puppet-agent`

#### [String] version

The version of the package to be installed. The default is provided by Hiera.

#### [String] ensure

Ensure if the package is `installed` or `absent`, the default is `installed`

## `puppet5::agent::config`

This class manages the `puppet.conf` configuration file. This module _only_ uses `puppet.conf` to manage the `[main]` and `[agent]` sections, configuration of other Puppet services will be in their own independent configuration files.

### Parameters

#### [Array[String]] basemodulepaths

An array of paths used to set the basemoduelpath setting that lists the directories where puppet checks for modules. Due to an [issue with how Puppet 5.0.0](https://tickets.puppetlabs.com/browse/PUP-7760) converts an `Array` to a `String`, spaces are stripped from paths when they substituted into `puppet.conf`

#### [String] ensure

If set to 'present' `puppet.conf` is deployed, if 'absent' it is removed. Default 'installed'

#### [String] server

Sets the fully qualified domain name, resovable name, or IP address of a puppet server or puppet master. Default leaves this unset.

#### [String] environment

Sets the puppet environment. Default leaves this unset.

#### [String] runinterval

Sets how often the puppet agent runs. Default leaves this unset. the `puppet-agent` will run every 30m by default.

## `puppet5::agent::service`

This class manages the state of the `puppet-agent` service.

### Parameters

#### [String] ensure

If set to 'enabled' the `puppet-agent` service runs at boot.

## `puppet5::oscheck`

This internal class has no paramters. Used by other classes to check if the `puppet5` module is being used on a supported operating system.

## `puppet5::repos`

This class installs the Puppetlabs repositories for installing Puppet5. While this module requires a package repostory to provide the Puppet v5.x packages for installation, it does not depend on the Puppetlabs repository or this class. 

### Parameters

# Hiera
Many things are defined in Hiera that are not controlled by parameters. These can be over-ridden in a Hiera datastore on the local machine or Puppet server. Check the `data` directory for defaults.

# To Do

This module is incomplete, however as it already has some functionality around configuring the `puppet-agent` it's suitable for release.

The following features are still to be done:

## Other Operating Systems

The current focus is on RedHat/CentOS 7, some `el6` support is included by may not be complete or thoroughly tested. Other operating systems are being considerd

- **Redhat/CentOS 5**: This module should also be compatible with `el5` once `el6` support is complete
- **SUSE/OpenSUSE**: We have a use case.
- **Debian/Ubuntu**: Should be straightforward, will only go back as far as 14.04 LTS.
- **Windows**: Maybe.
- **AIX**: No. We don't do that anymore.

## Puppet Software

- `puppetdb`: it should configure; puppet-agent, puppetserver and the puppetb. It may be possible to set up `puppet-agent` to use a `puppetdb` service directly in deployments without a `puppetserver`
- `puppetserver`: it should set up a `puppetserver` that's integrated with a `puppetdb` that can be local or remote, and some kind of dashboard.
- `hiera`: it should only set up the configuration and the data store directory structure, but not the content of the data store.
