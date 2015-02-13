[![Puppet Forge](http://img.shields.io/puppetforge/v/theforeman/puppet.svg)](https://forge.puppetlabs.com/theforeman/puppet)
[![Build Status](https://travis-ci.org/theforeman/puppet-puppet.svg?branch=master)](https://travis-ci.org/theforeman/puppet-puppet)

# Puppet module for installing the Puppet agent and master

Installs and configures the Puppet agent and optionally a Puppet master (when
`server` is true).  Part of the [Foreman installer](http://github.com/theforeman/foreman-installer)
or to be used as a Puppet module.

The Puppet master is configured under Apache and Passenger by default, unless
`server_passenger` is set to false.  Alternatively, set `server_implementation`
to `puppetserver` to switch to the JVM-based Puppet Server.

Many puppet.conf options for agents, masters and other are parameterized, with
class documentation provided at the top of the manifests. In addition, there
are hash parameters for each configuration section that can be used to supply
any options that are not explicitly supported.

## Environments support

The module helps configure Puppet environments using directory environments on
Puppet 3.6+ and config environments on older versions.  These are set up under
/etc/puppet/environments/ - change `server_environments` to define the list to
create, or use `puppet::server::env` for more control.

## Git repo support

Environments can be backed by git by setting `server_git_repo` to true, which
sets up `/var/lib/puppet/puppet.git` where each branch maps to one environment.
Avoid using 'master' as this name isn't permitted.  On each push to the repo, a
hook updates `/etc/puppet/environments` with the contents of the branch.

Requires [theforeman/git](https://forge.puppetlabs.com/theforeman/git).

## Foreman integration

With the 3.0.0 release the Foreman integration became optional.  It will still
by default install the Foreman integration when `server` is true,
so if you wish to run a Puppet master without Foreman, it can be disabled by
setting `server_foreman` to false.

Requires [theforeman/foreman](https://forge.puppetlabs.com/theforeman/foreman).

## PuppetDB integration

The Puppet master can be configured to export catalogs and reports to a
PuppetDB instance, using the puppetlabs/puppetdb module.  Use its
`puppetdb::server` class to install PuppetDB and this module to configure the
Puppet master.

Requires [puppetlabs/puppetdb](https://forge.puppetlabs.com/puppetlabs/puppetdb).

# Installation

Available from GitHub (via cloning or tarball), [Puppet Forge](https://forge.puppetlabs.com/theforeman/puppet)
or as part of the Foreman installer.

# Usage

As a parameterized class, all the configurable options can be overridden from your
wrapper classes or even your ENC (if it supports param classes). For example:

    # Agent and cron (or daemon):
    class { '::puppet': runmode => 'cron' }

    # Agent and puppetmaster:
    class { '::puppet': server => true }

    # You want to use git?
    class { '::puppet':
      server          => true
      server_git_repo => true
    }

    # You need need your own template for puppet.conf?
    class { '::puppet':
      agent_template  => 'puppetagent/puppet.conf.core.erb',
      server          => true,
      server_template => 'puppetserver/puppet.conf.master.erb',
    }

    # Maybe you're using gitolite, new hooks, and a different port?
    class { '::puppet':
      server                   => true
      server_port              => 8141,
      server_git_repo          => true,
      server_git_repo_path     => '/var/lib/gitolite/repositories/puppet.git',
      server_post_hook_name    => 'post-receive.puppet',
      server_post_hook_content => 'puppetserver/post-hook.puppet',
    }

    # Configure master without Foreman integration
    class { '::puppet':
      server                => true,
      server_foreman        => false,
      server_reports        => 'store',
      server_external_nodes => '',
    }

    # Want to integrate with an existing PuppetDB?
    class { '::puppet':
      server               => true,
      server_puppetdb_host => 'mypuppetdb.example.com',
      server_reports       => 'puppetdb,foreman',
      storeconfigs         => true,
      storeconfigs_backend => 'puppetdb',
    }

Look in _init.pp_ for what can be configured this way, see Contributing if anything
doesn't work.

To use this in standalone mode, edit a file (e.g. install.pp), put in a class resource,
as per the examples above, and the execute _puppet apply_ e.g:

    cat > install.pp <<EOF
    class { '::puppet': server => true }
    EOF
    puppet apply install.pp --modulepath /path_to/extracted_tarball

# Contributing

* Fork the project
* Commit and push until you are happy with your contribution

# More info

See http://theforeman.org or at #theforeman irc channel on freenode

Copyright (c) 2010-2012 Ohad Levy

This program and entire repository is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
