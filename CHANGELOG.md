# Changelog

## 2.1.2
* Remove Puppet agent '--disable' lock file on Debian
* Treat puppet-lint warnings as failures

## 2.1.1
* Add server_strict_variables parameter
* Update auth.conf from Puppet 3.5
* Ensure /etc/default/puppet has START=yes on Debian
* Set explicit ownership and mode on puppet.conf
* Move show_diff from agent section to main for puppet apply
* Pin to Rake 10.2.0 on Ruby 1.8

## 2.1.0
* Add a server_ca_proxy parameter for real Puppet CA hostname
* Add a allow_any_crl parameter to allow access to the CRL (#4345)
* Update to puppetlabs-apache 1.0
* Remove template source from header for Puppet 3.5 compatibility
* Only show ca_server if non-empty
* Fix missing dependency on foreman module
* Fix Modulefile specification for Forge compatibility
* Fix puppet::server::env with config_version set
* Ensure apache::mod::passenger is included
* Update puppet agent service name for Fedora 19
* Refactor puppet::config

## 2.0.0
* Switch to puppetlabs-apache from theforeman-apache
* Split agent configuration into puppet::agent::*
* Move $puppet::server_vardar into server::install
* Puppet 2.6 support removed
* Add class parameters to puppet::server::passenger
* Specify site.pp file mode to workaround PUP-1255
* Fix stdlib dependency for librarian-puppet
* Drop Puppet 3.0 and 3.1 tests
* Update tests for rspec-puppet 1.0.0

## 1.4.0
* Use concat to build puppet.conf and environment sections (Mickaël Canévet)
* Add classfile parameter (Mickaël Canévet)
* Add server_certname parameter for puppetmaster certname (Mickaël Canévet)
* Set cron hour and minutes according to runinterval (Mickaël Canévet)
* Add cron_cmd parameter (Mickaël Canévet)
* Add configtimeout parameter (Mickaël Canévet)
* Notify agent service when configs change
* Fix SSL parameter pass-through for Foreman puppetmaster setup
* Change fixture URLs from git:// to https:// (Guido Günther)
