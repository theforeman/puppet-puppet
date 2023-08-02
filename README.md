[![Puppet Forge](https://img.shields.io/puppetforge/v/theforeman/puppet.svg)](https://forge.puppetlabs.com/theforeman/puppet)
[![CI](https://github.com/theforeman/puppet-puppet/actions/workflows/ci.yml/badge.svg?event=schedule)](https://github.com/theforeman/puppet-puppet/actions/workflows/ci.yml)

# Puppet module for installing the Puppet agent and server

Installs and configures the Puppet agent and optionally a Puppet server (when
`server` is true).  Part of the [Foreman installer](https://github.com/theforeman/foreman-installer)
or to be used as a Puppet module.

Many puppet.conf options for agents, servers and other are parameterized, with
class documentation provided at the top of the manifests. In addition, there
are hash parameters for each configuration section that can be used to supply
any options that are not explicitly supported.

## Compatibility

See the module metadata for supported operating systems and compatible Puppet
versions. The Puppetserver version should also match this.

## Environments support

The module helps configure Puppet environments using directory environments.
These are set up under /etc/puppetlabs/code/environments.

## Git repo support

Environments can be backed by git by setting `server_git_repo` to true, which
sets up `/var/lib/puppet/puppet.git` where each branch maps to one environment.
Avoid using 'server' as this name isn't permitted.  On each push to the repo, a
hook updates `/etc/puppet/environments` with the contents of the branch.

Requires [theforeman/git](https://forge.puppetlabs.com/theforeman/git).

## Foreman integration

The Foreman integration is optional, but on by default when `server` is true.
It can be disabled by setting `server_foreman` to false.

Requires [theforeman/puppetserver_foreman](https://forge.puppetlabs.com/theforeman/puppetserver_foreman).

Since version 15.0.0 the integration bits depend on the standalone module where
previously it depended on
[theforeman/foreman](https://forge.puppetlabs.com/theforeman/foreman)

There is also optional integration for [katello/certs](https://forge.puppetlabs.com/katello/certs).
This can be enabled via Hiera:

```yaml
puppet::server::foreman::katello: true
```

Then the `foreman_ssl_{ca,cert,key}` parameters are ignored and `certs::puppet` is used as a source.

## PuppetDB integration

The Puppet server can be configured to export catalogs and reports to a
PuppetDB instance, using the puppetlabs/puppetdb module.  Use its
`puppetdb::server` class to install the PuppetDB server and this module to
configure the Puppet server to connect to PuppetDB.

Requires [puppetlabs/puppetdb](https://forge.puppetlabs.com/puppetlabs/puppetdb)

```puppet
class { 'puppet':
  server              => true,
  server_reports      => 'puppetdb,foreman',
  server_storeconfigs => true,
}
class { 'puppet::server::puppetdb':
  server => 'mypuppetdb.example.com',
}
```

Above example manages Puppetserver + PuppetDB integration. It won't install the
PuppetDB. To do so, you also need the `puppetdb` class

```puppet
class { 'puppet':
  server              => true,
  server_reports      => 'puppetdb,foreman',
  server_storeconfigs => true,
}
include puppetdb
class { 'puppet::server::puppetdb':
  server => 'mypuppetdb.example.com',
}
```

Then the PuppetDB module will also configure postgresql and setup the database.
If you want to manage postgresql installation on your own:

```puppet
class { 'postgresql::globals':
  encoding            => 'UTF-8',
  locale              => 'en_US.UTF-8',
  version             => '15',
  manage_package_repo => true,
}
class { 'postgresql::server':
  listen_addresses => '127.0.0.1',
}
postgresql::server::extension { 'pg_trgm':
  database => 'puppetdb',
  require  => Postgresql::Server::Db['puppetdb'],
  before   => Service['puppetdb'],
}
class { 'puppetdb':
  manage_dbserver => false,
}
class { 'puppet::server::puppetdb':
  server => 'mypuppetdb.example.com',
}
```

Above code will install Puppetserver/PuppetDB/PostgreSQL on a single server. It
will use the upstream postgresql repositories. It was tested on Ubuntu.

Please also make sure your puppetdb ciphers are compatible with your puppet server ciphers, ie that the two following parameters match:
```
puppet::server::cipher_suites
puppetdb::server::cipher_suites
```

# Installation

Available from GitHub (via cloning or tarball), [Puppet Forge](https://forge.puppetlabs.com/theforeman/puppet)
or as part of the Foreman installer.

# Usage

As a parameterized class, all the configurable options can be overridden from your
wrapper classes or even your ENC (if it supports param classes). For example:

```puppet
# Agent and cron (or daemon):
class { 'puppet': runmode => 'cron', agent_server_hostname => 'hostname' }

# Agent and puppetserver:
class { 'puppet': server => true }

# You want to use git?
class { 'puppet':
  server          => true
  server_git_repo => true
}

# Maybe you're using gitolite, new hooks, and a different port?
class { 'puppet':
  server                   => true
  server_port              => 8141,
  server_git_repo          => true,
  server_git_repo_path     => '/var/lib/gitolite/repositories/puppet.git',
  server_post_hook_name    => 'post-receive.puppet',
  server_post_hook_content => 'puppetserver/post-hook.puppet',
}

# Configure server without Foreman integration
class { 'puppet':
  server                => true,
  server_foreman        => false,
  server_reports        => 'store',
  server_external_nodes => '',
}

# Want to integrate with an existing PuppetDB?
class { 'puppet':
  server              => true,
  server_reports      => 'puppetdb,foreman',
  server_storeconfigs => true,
}
class { 'puppet::server::puppetdb':
  server => 'mypuppetdb.example.com',
}
```

Look in _init.pp_ for what can be configured this way, see Contributing if anything
doesn't work.

To use this in standalone mode, edit a file (e.g. install.pp), put in a class resource,
as per the examples above, and the execute _puppet apply_ e.g:

```sh
puppet apply --modulepath /path_to/extracted_tarball <<EOF
class { 'puppet': server => true }
EOF
```

# Advanced scenarios

An HTTP (non-SSL) puppetserver instance can be set up (standalone or in addition to
the SSL instance) by setting the `server_http` parameter to `true`. This is useful for
reverse proxy or load balancer scenarios where the proxy/load balancer takes care of SSL
termination. The HTTP puppetserver instance expects the `X-Client-Verify`, `X-SSL-Client-DN`
and `X-SSL-Subject` HTTP headers to have been set on the front end server.

The listening port can be configured by setting `server_http_port` (which defaults to 8139).

For puppetserver, this HTTP instance accepts **ALL** connections and no further restrictions can be configured.

**Note that running an HTTP puppetserver is a huge security risk when improperly
configured. Allowed hosts should be tightly controlled; anyone with access to an allowed
host can access all client catalogues and client certificates.**

```puppet
# Configure an HTTP puppetserver vhost in addition to the standard SSL vhost
class { '::puppet':
  server               => true,
  server_http          => true,
  server_http_port     => 8130, # default: 8139
}
```

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
