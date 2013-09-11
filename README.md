# Puppet module for installing Puppet agent, and Puppet server

Installs Puppet agent:

Optional support for installation of a Puppetmaster (using server => true)

  * Configurable support for static or git-backed dynamic environments (requires puppet-git module)
  * Storeconfig options (off, ActiveRecord or PuppetDB)
  * Passenger support (requires puppet-apache and puppet-passenger modules)

# Installation

## Using GIT

git clone git://github.com/theforeman/puppet-puppet.git

## Downloadable Tarball

  * http://github.com/theforeman/puppet-puppet/tarball/master

# Requirements

Only really tested on RedHat and Debian. Patches welcome for other OSes :)

# Setup

This is a parameterized class, but the defaults should get you going:

Standalone agent with defaults:

    echo include puppet | puppet --modulepath /path_to/extracted_tarball

# Customization

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

    # Perhaps you want to install without foreman?
    class { '::puppet':
      server                => true,
      server_reports        => 'store',
      server_external_nodes => '',
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
