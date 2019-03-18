[![Puppet Forge](https://img.shields.io/puppetforge/v/theforeman/puppet.svg)](https://forge.puppetlabs.com/theforeman/puppet)
[![Build Status](https://travis-ci.org/theforeman/puppet-puppet.svg?branch=master)](https://travis-ci.org/theforeman/puppet-puppet)

# Puppet module for installing the Puppet agent and master

Installs and configures the Puppet agent and optionally a Puppet master (when
`server` is true).  Part of the [Foreman installer](https://github.com/theforeman/foreman-installer)
or to be used as a Puppet module.

When using Puppet Server (version 5.3.6 is the lowest version, this module supports),
the module supports and assumes you will be installing the latest version.
If you know you'll be installing an earlier or specific version, you will
need to override `server_puppetserver_version`. More information in the Puppet
Server section below.

Many puppet.conf options for agents, masters and other are parameterized, with
class documentation provided at the top of the manifests. In addition, there
are hash parameters for each configuration section that can be used to supply
any options that are not explicitly supported.

## Environments support

The module helps configure Puppet environments using directory environments.
These are set up under /etc/puppetlabs/code/environments.

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
`puppetdb::server` class to install the PuppetDB server and this module to
configure the Puppet master to connect to PuppetDB.

Requires [puppetlabs/puppetdb](https://forge.puppetlabs.com/puppetlabs/puppetdb)

Please see the notes about using puppetlabs/puppetdb 5.x with older versions of Puppet (< 4.x) and PuppetDB (< 3.x) with
newer releases of the module and set the values via hiera or an extra include of `puppetdb::globals` with
`puppetdb_version` defined.

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
      server                      => true,
      server_puppetdb_host        => 'mypuppetdb.example.com',
      server_reports              => 'puppetdb,foreman',
      server_storeconfigs_backend => 'puppetdb',
    }

Look in _init.pp_ for what can be configured this way, see Contributing if anything
doesn't work.

To use this in standalone mode, edit a file (e.g. install.pp), put in a class resource,
as per the examples above, and the execute _puppet apply_ e.g:

    cat > install.pp <<EOF
    class { '::puppet': server => true }
    EOF
    puppet apply install.pp --modulepath /path_to/extracted_tarball

# Advanced scenarios

An HTTP (non-SSL) puppetmaster instance can be set up (standalone or in addition to
the SSL instance) by setting the `server_http` parameter to `true`. This is useful for
reverse proxy or load balancer scenarios where the proxy/load balancer takes care of SSL
termination. The HTTP puppetmaster instance expects the `X-Client-Verify`, `X-SSL-Client-DN`
and `X-SSL-Subject` HTTP headers to have been set on the front end server.

The listening port can be configured by setting `server_http_port` (which defaults to 8139).

For puppetserver, this HTTP instance accepts **ALL** connections and no further restrictions can be configured.

**Note that running an HTTP puppetmaster is a huge security risk when improperly
configured. Allowed hosts should be tightly controlled; anyone with access to an allowed
host can access all client catalogues and client certificates.**

    # Configure an HTTP puppetmaster vhost in addition to the standard SSL vhost
    class { '::puppet':
      server               => true,
      server_http          => true,
      server_http_port     => 8130, # default: 8139
    }

## Puppet Server configuration

Puppet Server requires slightly different configuration between different
versions, which this module supports. It's recommended that you set the
`server_puppetserver_version` parameter to the MAJOR.MINOR.PATCH version
you have installed. By default the module will configure for the latest
version available.

# Contributing

* Fork the project
* Commit and push until you are happy with your contribution

# More info

See https://theforeman.org or at #theforeman irc channel on freenode

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
along with this program.  If not, see <https://www.gnu.org/licenses/>.
