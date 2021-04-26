# Changelog

## [15.0.0](https://github.com/theforeman/puppet-puppet/tree/15.0.0) (2021-04-26)

[Full Changelog](https://github.com/theforeman/puppet-puppet/compare/14.2.1...15.0.0)

**Breaking changes:**

- \(\#780\) puppetserver: don't purge metrics.conf / Use dedicated parameter for jruby profiler  [\#781](https://github.com/theforeman/puppet-puppet/pull/781) ([bastelfreak](https://github.com/bastelfreak))
- Move to puppetserver\_foreman [\#749](https://github.com/theforeman/puppet-puppet/pull/749) ([ekohl](https://github.com/ekohl))

**Implemented enhancements:**

- Add `puppet::package_install_options` variable to allow you to pass flags to package resource [\#777](https://github.com/theforeman/puppet-puppet/pull/777) ([vollmerk](https://github.com/vollmerk))

**Fixed bugs:**

- Fix config append [\#782](https://github.com/theforeman/puppet-puppet/pull/782) ([SimonPe](https://github.com/SimonPe))

## [14.2.1](https://github.com/theforeman/puppet-puppet/tree/14.2.1) (2021-01-26)

[Full Changelog](https://github.com/theforeman/puppet-puppet/compare/14.2.0...14.2.1)

**Fixed bugs:**

- run Puppet agent from systemd only after network is brought up [\#765](https://github.com/theforeman/puppet-puppet/pull/765) ([anarcat](https://github.com/anarcat))

## [14.2.0](https://github.com/theforeman/puppet-puppet/tree/14.2.0) (2020-10-29)

[Full Changelog](https://github.com/theforeman/puppet-puppet/compare/14.1.0...14.2.0)

**Implemented enhancements:**

- adds param for user-provided puppetserver auth.conf [\#769](https://github.com/theforeman/puppet-puppet/pull/769) ([chadh](https://github.com/chadh))
- Add `server\_puppetserver\_trusted\_certificate\_extensions` [\#758](https://github.com/theforeman/puppet-puppet/pull/758) ([alexjfisher](https://github.com/alexjfisher))

**Fixed bugs:**

- Remove `systemd` from puppet::agent::service case [\#768](https://github.com/theforeman/puppet-puppet/pull/768) ([alexjfisher](https://github.com/alexjfisher))

**Merged pull requests:**

- Remove unused parameter docs [\#767](https://github.com/theforeman/puppet-puppet/pull/767) ([alexjfisher](https://github.com/alexjfisher))
- Remove duplicate docs [\#766](https://github.com/theforeman/puppet-puppet/pull/766) ([alexjfisher](https://github.com/alexjfisher))

## [14.1.0](https://github.com/theforeman/puppet-puppet/tree/14.1.0) (2020-08-05)

[Full Changelog](https://github.com/theforeman/puppet-puppet/compare/14.0.0...14.1.0)

**Implemented enhancements:**

- Use server\_trusted\_agents in v4 catalog endpoint [\#756](https://github.com/theforeman/puppet-puppet/pull/756) ([alexjfisher](https://github.com/alexjfisher))
- also allow whitelisted admin clients to clean certs [\#748](https://github.com/theforeman/puppet-puppet/pull/748) ([foxxx0](https://github.com/foxxx0))

**Fixed bugs:**

- Don't re-create existing CA certs [\#747](https://github.com/theforeman/puppet-puppet/pull/747) ([zipkid](https://github.com/zipkid))

## [14.0.0](https://github.com/theforeman/puppet-puppet/tree/14.0.0) (2020-05-14)

[Full Changelog](https://github.com/theforeman/puppet-puppet/compare/13.0.0...14.0.0)

**Breaking changes:**

- Use modern facts [\#743](https://github.com/theforeman/puppet-puppet/issues/743)
- Drop EOL Windows 7, 2008 R2 [\#739](https://github.com/theforeman/puppet-puppet/pull/739) ([ekohl](https://github.com/ekohl))
- Drop Foreman API version parameters [\#736](https://github.com/theforeman/puppet-puppet/pull/736) ([ekohl](https://github.com/ekohl))
- Refactor PuppetDB integration [\#732](https://github.com/theforeman/puppet-puppet/pull/732) ([ekohl](https://github.com/ekohl))

**Implemented enhancements:**

- Support Ubuntu Focal \(20.04\) [\#746](https://github.com/theforeman/puppet-puppet/pull/746) ([mmoll](https://github.com/mmoll))
- Fixes [\#29735](https://projects.theforeman.org/issues/29735) - support el8 [\#742](https://github.com/theforeman/puppet-puppet/pull/742) ([wbclark](https://github.com/wbclark))
- Switch AIO detection to use aio\_agent\_version fact [\#737](https://github.com/theforeman/puppet-puppet/pull/737) ([ekohl](https://github.com/ekohl))
- Allow extlib 5.x [\#733](https://github.com/theforeman/puppet-puppet/pull/733) ([mmoll](https://github.com/mmoll))
- Add server\_trusted\_external\_command parameter [\#731](https://github.com/theforeman/puppet-puppet/pull/731) ([baurmatt](https://github.com/baurmatt))
- Add server\_ca\_client\_self\_delete to CA Servers [\#728](https://github.com/theforeman/puppet-puppet/pull/728) ([neilfromit](https://github.com/neilfromit))
- implement 'versioned code' for puppetserver [\#726](https://github.com/theforeman/puppet-puppet/pull/726) ([mmoll](https://github.com/mmoll))

**Closed issues:**

- Systemd dependency missing [\#704](https://github.com/theforeman/puppet-puppet/issues/704)

**Merged pull requests:**

- Add Fedora 31, drop Fedora 26 [\#745](https://github.com/theforeman/puppet-puppet/pull/745) ([ekohl](https://github.com/ekohl))

## [13.0.0](https://github.com/theforeman/puppet-puppet/tree/13.0.0) (2020-02-12)

[Full Changelog](https://github.com/theforeman/puppet-puppet/compare/12.1.0...13.0.0)

**Breaking changes:**

- Update cipher suites [\#721](https://github.com/theforeman/puppet-puppet/pull/721) ([mmoll](https://github.com/mmoll))
- Drop listen parameter [\#718](https://github.com/theforeman/puppet-puppet/pull/718) ([ekohl](https://github.com/ekohl))

**Implemented enhancements:**

- Add server\_multithreaded parameter [\#720](https://github.com/theforeman/puppet-puppet/pull/720) ([alexjfisher](https://github.com/alexjfisher))
- Add Debian 10 [\#716](https://github.com/theforeman/puppet-puppet/pull/716) ([mmoll](https://github.com/mmoll))

**Fixed bugs:**

- Restart Puppet Agent service after updating the package [\#712](https://github.com/theforeman/puppet-puppet/pull/712) ([fraenki](https://github.com/fraenki))

**Merged pull requests:**

- Move parameters to advanced [\#719](https://github.com/theforeman/puppet-puppet/pull/719) ([ekohl](https://github.com/ekohl))
- Stop acceptance tests on EL7 [\#715](https://github.com/theforeman/puppet-puppet/pull/715) ([ekohl](https://github.com/ekohl))

## [12.1.0](https://github.com/theforeman/puppet-puppet/tree/12.1.0) (2019-10-25)

[Full Changelog](https://github.com/theforeman/puppet-puppet/compare/12.0.1...12.1.0)

**Implemented enhancements:**

- Ensure config file ends with a new line [\#707](https://github.com/theforeman/puppet-puppet/pull/707) ([baurmatt](https://github.com/baurmatt))

**Merged pull requests:**

- Document campotocamp/systemd soft dependency [\#696](https://github.com/theforeman/puppet-puppet/pull/696) ([dogjarek](https://github.com/dogjarek))

## [12.0.1](https://github.com/theforeman/puppet-puppet/tree/12.0.1) (2019-06-13)

[Full Changelog](https://github.com/theforeman/puppet-puppet/compare/12.0.0...12.0.1)

**Merged pull requests:**

- Allow puppetlabs/concat 6.x and puppet/extlib 4.x [\#700](https://github.com/theforeman/puppet-puppet/pull/700) ([alexjfisher](https://github.com/alexjfisher))
- Allow `puppetlabs/stdlib` 6.x [\#698](https://github.com/theforeman/puppet-puppet/pull/698) ([alexjfisher](https://github.com/alexjfisher))

## [12.0.0](https://github.com/theforeman/puppet-puppet/tree/12.0.0) (2019-04-17)

[Full Changelog](https://github.com/theforeman/puppet-puppet/compare/11.0.1...12.0.0)

**Breaking changes:**

- Use current timeout management variables [\#693](https://github.com/theforeman/puppet-puppet/pull/693) ([ekohl](https://github.com/ekohl))
- remove Debian 8 support [\#688](https://github.com/theforeman/puppet-puppet/pull/688) ([mmoll](https://github.com/mmoll))
- drop Puppet 4 [\#685](https://github.com/theforeman/puppet-puppet/pull/685) ([mmoll](https://github.com/mmoll))
- drop EOL OSes [\#684](https://github.com/theforeman/puppet-puppet/pull/684) ([mmoll](https://github.com/mmoll))

**Implemented enhancements:**

- Configurable minute and hour for cronjob and systemd.timer [\#690](https://github.com/theforeman/puppet-puppet/pull/690) ([mauricemeyer](https://github.com/mauricemeyer))
- add Puppetserver 6.3 auth.conf update [\#689](https://github.com/theforeman/puppet-puppet/pull/689) ([mmoll](https://github.com/mmoll))
- add 2018 to osreleasemajor for agent\_restart\_command  [\#686](https://github.com/theforeman/puppet-puppet/pull/686) ([cabrinha](https://github.com/cabrinha))
- Handle the pluginsync setting deprecation [\#683](https://github.com/theforeman/puppet-puppet/pull/683) ([ekohl](https://github.com/ekohl))
- Move client\_certname to \[main\] [\#681](https://github.com/theforeman/puppet-puppet/pull/681) ([baurmatt](https://github.com/baurmatt))
- Implement $server\_max\_open\_files [\#671](https://github.com/theforeman/puppet-puppet/pull/671) ([baurmatt](https://github.com/baurmatt))

## [11.0.1](https://github.com/theforeman/puppet-puppet/tree/11.0.1) (2019-04-02)

[Full Changelog](https://github.com/theforeman/puppet-puppet/compare/11.0.0...11.0.1)

**Fixed bugs:**

- Fixes [\#26199](https://projects.theforeman.org/issues/26199) - Fix dependency cycle when using git\_repo [\#682](https://github.com/theforeman/puppet-puppet/pull/682) ([ekohl](https://github.com/ekohl))
- Quick fix for Windows agent restart loop \#678 [\#679](https://github.com/theforeman/puppet-puppet/pull/679) ([anthonysomerset](https://github.com/anthonysomerset))

## [11.0.0](https://github.com/theforeman/puppet-puppet/tree/11.0.0) (2019-01-14)

[Full Changelog](https://github.com/theforeman/puppet-puppet/compare/10.1.0...11.0.0)

**Breaking changes:**

- Remove left over environment entry [\#662](https://github.com/theforeman/puppet-puppet/pull/662) ([ekohl](https://github.com/ekohl))
- remove apache dependency and leftovers [\#661](https://github.com/theforeman/puppet-puppet/pull/661) ([mmoll](https://github.com/mmoll))
- Remove dynamic and config environments [\#653](https://github.com/theforeman/puppet-puppet/pull/653) ([ekohl](https://github.com/ekohl))
- Remove passenger support [\#650](https://github.com/theforeman/puppet-puppet/pull/650) ([ekohl](https://github.com/ekohl))
- Drop support for puppetserver \< 2.7 [\#649](https://github.com/theforeman/puppet-puppet/pull/649) ([ekohl](https://github.com/ekohl))
- namespace extlib functions [\#639](https://github.com/theforeman/puppet-puppet/pull/639) ([mmoll](https://github.com/mmoll))

**Implemented enhancements:**

- Fixes [\#25839](https://projects.theforeman.org/issues/25839) - Determine puppetserver version in server.pp [\#668](https://github.com/theforeman/puppet-puppet/pull/668) ([ekohl](https://github.com/ekohl))
- Remove $deb\_naio\_package & puppet-common install [\#665](https://github.com/theforeman/puppet-puppet/pull/665) ([ekohl](https://github.com/ekohl))
- Config file updates and FreeBSD refactorings [\#664](https://github.com/theforeman/puppet-puppet/pull/664) ([mmoll](https://github.com/mmoll))
- Set more data types and document classes & defines [\#663](https://github.com/theforeman/puppet-puppet/pull/663) ([ekohl](https://github.com/ekohl))
- Add unmanaged Puppet Agent runmode [\#659](https://github.com/theforeman/puppet-puppet/pull/659) ([Rathios](https://github.com/Rathios))

**Merged pull requests:**

- add Puppetserver 5.x upgrade test [\#667](https://github.com/theforeman/puppet-puppet/pull/667) ([mmoll](https://github.com/mmoll))

## [10.1.0](https://github.com/theforeman/puppet-puppet/tree/10.1.0) (2018-12-06)

[Full Changelog](https://github.com/theforeman/puppet-puppet/compare/10.0.0...10.1.0)

**Implemented enhancements:**

- Add support for managing jetty threads [\#647](https://github.com/theforeman/puppet-puppet/pull/647) ([bastelfreak](https://github.com/bastelfreak))
- Refactor testing and use data types in private classes [\#645](https://github.com/theforeman/puppet-puppet/pull/645) ([ekohl](https://github.com/ekohl))
- Update CA related files for Puppetserver 5.3.6 [\#643](https://github.com/theforeman/puppet-puppet/pull/643) ([mmoll](https://github.com/mmoll))
- Add Puppet 6 support [\#642](https://github.com/theforeman/puppet-puppet/pull/642) ([ekohl](https://github.com/ekohl))

**Fixed bugs:**

- adjust puppetversion to puppetserver\_version mapping [\#651](https://github.com/theforeman/puppet-puppet/pull/651) ([mmoll](https://github.com/mmoll))

## [10.0.0](https://github.com/theforeman/puppet-puppet/tree/10.0.0) (2018-10-16)

[Full Changelog](https://github.com/theforeman/puppet-puppet/compare/9.1.0...10.0.0)

**Breaking changes:**

- don't use pupetlabs-hocon for metrics.conf [\#622](https://github.com/theforeman/puppet-puppet/pull/622) ([mmoll](https://github.com/mmoll))
- Revert "use puppetlabs-hocon for webserver.conf" [\#620](https://github.com/theforeman/puppet-puppet/pull/620) ([mmoll](https://github.com/mmoll))
- Revert "use puppetlabs-hocon for product.conf" [\#618](https://github.com/theforeman/puppet-puppet/pull/618) ([mmoll](https://github.com/mmoll))
- Revert "use puppetlabs-{hocon, puppet\_authorization} for auth.conf [\#615](https://github.com/theforeman/puppet-puppet/pull/615) ([mmoll](https://github.com/mmoll))

**Implemented enhancements:**

- reduce diff to Puppet distributed files [\#638](https://github.com/theforeman/puppet-puppet/pull/638) ([mmoll](https://github.com/mmoll))
- Make `splaylimit` & `runinterval` types consistent [\#623](https://github.com/theforeman/puppet-puppet/pull/623) ([alexjfisher](https://github.com/alexjfisher))
- add status service endpoint [\#621](https://github.com/theforeman/puppet-puppet/pull/621) ([mmoll](https://github.com/mmoll))
- updated auth.conf for the "puppet facts upload" command \(puppetserver 5.5\) [\#619](https://github.com/theforeman/puppet-puppet/pull/619) ([slauger](https://github.com/slauger))
- Add ability to configure custom\_trusted\_oid\_mapping.yaml [\#603](https://github.com/theforeman/puppet-puppet/pull/603) ([baurmatt](https://github.com/baurmatt))

**Fixed bugs:**

- Add shared gem path for Puppetserver \>= 5.3 [\#631](https://github.com/theforeman/puppet-puppet/pull/631) ([baurmatt](https://github.com/baurmatt))

**Merged pull requests:**

- Allow puppet/extlib 3 [\#637](https://github.com/theforeman/puppet-puppet/pull/637) ([alexjfisher](https://github.com/alexjfisher))
- Use facter 3 facts during tests [\#636](https://github.com/theforeman/puppet-puppet/pull/636) ([alexjfisher](https://github.com/alexjfisher))
- Contain classes [\#635](https://github.com/theforeman/puppet-puppet/pull/635) ([ekohl](https://github.com/ekohl))
- Use `contain` instead of `anchor` pattern [\#627](https://github.com/theforeman/puppet-puppet/pull/627) ([alexjfisher](https://github.com/alexjfisher))
- removing redundant \> character [\#626](https://github.com/theforeman/puppet-puppet/pull/626) ([attachmentgenie](https://github.com/attachmentgenie))
- allow puppetlabs-stdlib 5.x [\#625](https://github.com/theforeman/puppet-puppet/pull/625) ([mmoll](https://github.com/mmoll))
- allow puppetlabs-concat 5.x [\#624](https://github.com/theforeman/puppet-puppet/pull/624) ([mmoll](https://github.com/mmoll))

## [9.1.0](https://github.com/theforeman/puppet-puppet/tree/9.1.0) (2018-07-16)

[Full Changelog](https://github.com/theforeman/puppet-puppet/compare/9.0.3...9.1.0)

**Implemented enhancements:**

- Support Ubuntu/bionic, drop Debian 7 & Fedora 25 [\#605](https://github.com/theforeman/puppet-puppet/pull/605) ([mmoll](https://github.com/mmoll))

## [9.0.3](https://github.com/theforeman/puppet-puppet/tree/9.0.3) (2018-06-20)

[Full Changelog](https://github.com/theforeman/puppet-puppet/compare/9.0.1...9.0.3)

**Fixed bugs:**

- make foreman puppet module dir optional [\#600](https://github.com/theforeman/puppet-puppet/pull/600) ([bastelfreak](https://github.com/bastelfreak))

## [9.0.1](https://github.com/theforeman/puppet-puppet/tree/9.0.1) (2018-06-13)

[Full Changelog](https://github.com/theforeman/puppet-puppet/compare/9.0.0...9.0.1)

**Fixed bugs:**

- Support ssl-protocols option for puppetserver configuration [\#598](https://github.com/theforeman/puppet-puppet/pull/598) ([stbenjam](https://github.com/stbenjam))

## [9.0.0](https://github.com/theforeman/puppet-puppet/tree/9.0.0) (2018-05-29)

[Full Changelog](https://github.com/theforeman/puppet-puppet/compare/8.2.0...9.0.0)

**Breaking changes:**

- Remove unused \_template options [\#588](https://github.com/theforeman/puppet-puppet/pull/588) ([ekohl](https://github.com/ekohl))

**Implemented enhancements:**

- adding support for Amazon Linux [\#590](https://github.com/theforeman/puppet-puppet/pull/590) ([RobReus](https://github.com/RobReus))
- Allow reports to be disabled [\#587](https://github.com/theforeman/puppet-puppet/pull/587) ([sanyu](https://github.com/sanyu))
- Add systemd\_randomizeddelaysec [\#585](https://github.com/theforeman/puppet-puppet/pull/585) ([jcharaoui](https://github.com/jcharaoui))
- Allowing the package\_source to be an Httpurl [\#582](https://github.com/theforeman/puppet-puppet/pull/582) ([MAXxATTAXx](https://github.com/MAXxATTAXx))

**Fixed bugs:**

- Allow arrays for `server\_jvm\_extra\_args` parameter [\#596](https://github.com/theforeman/puppet-puppet/pull/596) ([alexjfisher](https://github.com/alexjfisher))
- Use the correct Stdlib::HTTPUrl [\#584](https://github.com/theforeman/puppet-puppet/pull/584) ([ekohl](https://github.com/ekohl))

**Merged pull requests:**

- Move some settings into an advanced section [\#589](https://github.com/theforeman/puppet-puppet/pull/589) ([ekohl](https://github.com/ekohl))
- Remove duplicate with ca\_port test [\#583](https://github.com/theforeman/puppet-puppet/pull/583) ([ekohl](https://github.com/ekohl))
- permit puppetlabs-apache 3.x [\#581](https://github.com/theforeman/puppet-puppet/pull/581) ([mmoll](https://github.com/mmoll))
- Cosmetic fix to metadata.json [\#580](https://github.com/theforeman/puppet-puppet/pull/580) ([alexjfisher](https://github.com/alexjfisher))

## [8.2.0](https://github.com/theforeman/puppet-puppet/tree/8.2.0) (2018-01-25)

[Full Changelog](https://github.com/theforeman/puppet-puppet/compare/8.1.0...8.2.0)

**Implemented enhancements:**

- Make max-queued-requests and max-retry-delay configurable [\#569](https://github.com/theforeman/puppet-puppet/issues/569)
- add compile\_mode parameter to puppetserver.conf [\#574](https://github.com/theforeman/puppet-puppet/pull/574) ([miksercz](https://github.com/miksercz))
- Make performance tuning defaults more safe [\#572](https://github.com/theforeman/puppet-puppet/pull/572) ([kasimon](https://github.com/kasimon))
- Add `server_max_queued_requests` and `server_max_retry_delay` parameters [\#570](https://github.com/theforeman/puppet-puppet/pull/570) ([baurmatt](https://github.com/baurmatt))

## 8.1.0

* Set the codedir in puppet.conf
* Improve parameter documentation around versions
* Stop shipping development code (spec, Rakefile, Gemfile) in releases
* Remove EOL OSes and add new ones to metadata.json
* Avoid duplicate declaration issues when `server_additonal_settings` and `additional_settings` contain same key
* Re-add the /usr/share/puppet/modules directory to the default `server_common_modules_path`
* Add configuration of puppetserver graphite metrics
* Always manage the puppet user
* Remove code for Puppet < 4.5 and Puppetserver < 2.2
* Add `puppetserver_trusted_agents` parameter
* use puppetlabs-hocon for authconf, ca.conf, product.conf and webserver.conf
* Add `server_jvm_cli_args` parameter

## 8.0.4
* Bump allowed version of puppet-extlib to 3.0.0

## 8.0.3
* Add support for Puppetserver 5.1 configurations.

## 8.0.2
* Handle FreeBSD puppet5 package
* Make `puppet::server::passenger::ssl_protocol` and `puppet::server::passenger::ssl_cipher` parameters to allow overriding via hiera

## 8.0.1
* Handle $::memorysize_mb and $::processorcount correctly when using facter 2.x
* Fix `client_package` puppet type, restoring full compatibility with older versions
* update common_modules_path to work in the server::config subclass

## 8.0.0
* Drop Puppet 3 support in the module code. Having Puppet 3 agents configured by a Puppet 4 server still works.
* New or changed parameters:
    * The `$server_enable_ruby_profiler` parameter got removed and rolled into `$server_puppetserver_metrics`.
    * Add `$server_puppetserver_metrics` parameter to control if metrics (Puppetserver 5 only) and JRuby profiling
      are enabled.
    * Add `$server_puppetserver_jruby9k` parameter to allow JRuby 9000 to be used as Ruby for Puppetserver.
    * Add `$server_puppetserver_experimental` parameter to enable the /puppet/experimental route in Puppetserver 5.
    * Add `$autosign_source` parameter. If set, this is used as source for the autosign file, instead of
      `$autosign_content`.
    * The `$server_enc_api` parameter does not accept `v1` as API anymore.
    * Add `$server_web_idle_timeout` parameter for setting the in ms that Jetty allows a socket to be idle after
      processing has completed.
    * The `$client_certname` parameter can now be set to a boolean. This can be used to prevent `certname` being set.
* Other features:
    * Add support for Puppetserver 5 configurations.
* Other changes and fixes:
    * Stop accepting Foreman Puppetmaster v1 APIs.
    * Move the `server` config parameter to the `[main]` section of puppet.conf.
    * Puppetserver's `web-routes.conf` is not managed anymore, as that has led to a number of bugs when upgrading to
      newer versions of Puppetserver.

## 7.1.1
* Other changes and fixes:
    * Add Puppet 3 client compatibility under rack

## 7.1.0
* New or changed parameters:
    * Add `$autosign_content` parameter to supply content for the autosign file.
    * Add `$ca_crl_filepath`, `$server_ca_crl_sync` and `$server_crl_enable`
      parameters. This allows the CRL to be enabled when `puppet_ca` is
      disabled and provides the ability to sync `#{ssldir}/ca/ca_crl.pem`
      contents to `#{ssldir}/crl.pem` from a master of masters.
    * Add `$server_ssl_key_manage` parameter to disable the standard private
      key management which eases external certificate and key handling.
    * Add `$server_ssl_chain_filepath` parameter, to specify the value of
      `ssl-cert-chain` in the `webserver.conf` file for puppetserver.
    * Add `$server_allow_header_cert_info` parameter to set
      `allow-header-cert-info` for puppetserver independently from the
      `$server_http` parameter.
* Other features:
    * Support native puppetserver package on FreeBSD
    * Allow disabling crl when `server_ca => true`
    * Add SLES AIO agent support
    * Add support for Parallels PSBM
* Other changes and fixes:
    * Lower JVM heap size when low memory is detected

## 7.0.2
* Other changes and fixes:
    * Handle removal of the native puppet-agent package in Debian 9
    * Generate Puppet cert with --allow-dns-alt-names
    * The server_package parameter should also take arrays

## 7.0.1
* Other changes and fixes:
    * Set vardir, rundir and logdir explicitly in puppet.conf
    * Fix undefined variable error when domain fact is missing

## 7.0.0
* New or changed parameters:
    * Add server_check_for_updates parameter to control update checking and
      data collection
    * Add server_environment_class_cache_enabled parameter to enable
      environment caching
    * Add server_max_requests_per_instance parameter to control number of
      requests each Puppet Server JRuby instance handles
    * Add server_puppetserver_rundir/vardir parameters
    * Rename server_facts parameter to server_foreman_facts to prevent a name
      clash with Puppet's trusted_server_facts (GH-440)
* Other features:
    * Add Puppet Server 2.7 support
    * Add `puppet::config::*` resources to manage configuration entries using
      concat files
    * Move ENC config into puppet::server::enc, allowing discovery via exported
      resources
    * Support HTTP configuration of Puppet Server via existing server_http
      parameter - this is open to all connections when enabled, and is not
      configurable.
    * Add Arch Linux agent support
* Other changes and fixes:
    * Change puppet.conf templates to use puppet::config resources
    * Fix auth.conf paths to certificate_status API endpoints
    * Fix initialisation of puppetmaster parameter with strict variables
    * Fix differences in Puppet Server config files from defaults
    * Fix ordering of Puppet CA generation to Foreman startup (#17133)
    * Fix refreshing of Puppet master under Passenger when ENC configuration
      is changed (#17062)
    * Permit extlib 1.x
    * Change parameter documentation to use Puppet 4 style typing
    * Remove pre-Puppet 3.4 umask support
* Compatibility warnings:
    * Minimum version of Puppet 3.6.0 is required
    * Drops support for Ruby 1.8.7
    * Drop FreeBSD 9.x support
    * server_facts parameter is now server_foreman_facts

## 6.0.1
* Other features:
    * Permit access to environment_classes Puppet Server API
* Other changes and fixes:
    * start Puppet agent after server is running
    * add full api path to certificate_status(es) in auth.conf

## 6.0.0
* New or changed parameters:
    * Add server_passenger_ruby parameter to change Rack Ruby interpreter
    * Add server_puppetserver_vardir parameter to set the Puppet Server vardir
      to a different location than the agent (SERVER-357)
    * Add server_envs_target parameter to create symlink in place of the
      environments directory
    * Add autosign_entries parameter to list certnames that will be added to
      autosign.conf for automatic signing
* Other features:
    * Support Debian non-AIO Puppet 4 packages
    * Enable HTTP to HTTPS proxying of CA requests on HTTP Puppet master vhost
    * List Fedora 24 compatibility
* Other changes and fixes:
    * Change default Puppet Server version to 2.6.0
    * Move CA and admin authorization/whitelist settings to auth.conf on Puppet
      Server 2.2 or higher
    * Remove non-functional Puppet 3 endpoints from auth.conf when using
      Puppet 4
    * Don't deploy empty site.pp file, not required on recent versions, and
      remove the server_manifest_path parameter
    * Add docs for using PuppetDB integration under pre-4.x versions of Puppet
    * Fix missing default parameters under strict variables
    * Fix Kafo data types in package parameter docs
    * Fix indentation and whitespace in puppet.conf templates
* Compatibility warnings:
    * Support for Puppet 3.2 or lower has been removed, 3.3.0 or higher is
      required
    * server_manifest_path has been removed

## 5.0.0
* New or changed parameters:
    * Add new server_* parameters for Puppet Server 2.x configuration options,
      including whitelists for admin/CA clients and Ruby/SSL options
    * Add server_puppetserver_version parameter, which should be set if not
      using the latest version of Puppet Server for correct configuration
    * Add server_use_legacy_auth_conf parameter for Puppet Server 2.0-2.1
      compatibility with pre-HOCON auth configs (GH-372)
    * Add server_ip for configuring the listen IP (puppetserver only)
    * Add server_main_template parameter for separate server puppet.conf lines
    * Add passenger_min_instances and passenger_pre_start for passenger tuning
    * Add client_certname to set a custom client certificate name (GH-378)
    * Allow server_common_modules_path to be unset to disable basemodulepath
    * Remove passenger_max_pool which had no effect
* Other features:
    * Support Puppet Server 2.x, defaulting to configuration for 2.4 and 2.5
    * Use puppetserver by default with AIO packages
    * Permit access to resource_type API for smart proxy support
* Other changes and fixes:
    * Paths to Puppet directories and configuration files updated for AIO
      agent and server locations
    * Use ip_to_cron from voxpupuli/extlib (GH-391)
    * Respect server_certname for Puppet Server SSL paths
    * Move default manifest creation to server config (GH-365)
    * Fix hiera_config location for Puppet 4.0-4.4
    * Fix ordering of server SSL directory before private_keys subdirectory
    * Fix ordering of foreman/foreman_proxy users to after server config
    * Fix puppet::server::env modulepath default to follow basedir parameter
    * Move server parameters and validation to puppet::server
    * Remove autosign from main puppet.conf section
    * Remove management of namespaceauth.conf
* Compatibility warnings:
    * The autosign parameter now takes only the path to the autosign file or
      a boolean. An additional parameter, autosign_mode, was added to set the
      file mode of the autosign file/script.
    * Support for Puppet 3.0.x has been removed, 3.1.0 or higher is required

## 4.3.2
* Other changes and fixes:
    * Add EL5 to service management conditionals (GH-404)

## 4.3.1
* Other changes and fixes:
    * set hiera_config correctly on puppet 4
    * let puppetdb_conf notify the puppetmaster service

## 4.3.0
* New or changed parameters:
    * Add server_git_repo_mode, group and user parameters for repo ownership
    * Add systemd.timer value to runmode parameter to run the agent from
      systemd timers, add systemd_cmd and systemd_unit_name parameters
    * Add unavailable_runmodes parameter to limit which _other_ runmodes are
      not possible when configuring the agent
* Other features:
    * Support Ubuntu 16.04
* Other changes and fixes:
    * Support Puppet 3.0 minimum
    * Use lower case FQDN to access Foreman from ENC/report processors (#8389)
    * Move reports setting to main puppet.conf section (GH-311)
    * Expose v1 /status endpoint in auth.conf (GH-338)
    * Update Puppet 3.8.x package name on FreeBSD
    * Fix default systemd and cron commands with AIO package (GH-340)
    * Fix ownership of environment.conf (GH-349, GH-350)
    * Support Fedora 21, remove Debian 6 (Squeeze)

## 4.2.0
* New or changed parameters:
    * Add codedir parameter, for Puppet code directory
    * Add package_source parameter to provide package location on Windows
    * Add dir_owner/dir_group parameters for base Puppet agent dir ownership
    * Add various server_jvm parameters to manage Puppet Server JVM settings
    * Add autosign parameter to override autosign.conf location or script
    * Add server_default_manifest parameters to manage the Puppet master's
      default manifest
    * Add server_ssl_dir_manage parameter to control presence of ssl_dir
* Other features:
    * Add Puppet agent AIO support
    * Manage Puppet 4 on FreeBSD
* Other changes and fixes:
    * Ensure server_manifest_path directory exists
    * Disable generation of Puppet CA when server_ca parameter is false
    * Fix parameter names in README example

## 4.1.0
* New or changed parameters:
    * Add sharedir parameter to configure /usr/share/puppet location
    * Add manage\_packages parameter to change whether to manage agent,
      master, both packages (true) or none (false)
* Other features:
    * Support Puppet master setup on FreeBSD
* Other changes and fixes:
    * Explicitly set permissions and ownership where necessary to stop
      site-wide defaults applying

## 4.0.1
* Update auth.conf for Puppet 4 API v3 endpoints
* Expand $ssldir in puppet.conf
* List incompatibility with puppetlabs/puppetdb 5.x

## 4.0.0
* New or changed parameters:
    * Add server\_http\_* parameters to configure the master to listen on HTTP
      for reverse proxy scenarios
    * Add server_version parameter to control package version of Puppet master
    * Add server\_environment\_timeout parameter to control caching of all
      environments
    * Add environment parameter to set the default Puppet agent environment
* Other features:
    * Replace theforeman/concat_native with puppetlabs/concat
    * Reload, not restart the Puppet agent service where possible
* Other changes and fixes:
    * Add documentation on environment parameters used with R10K
    * Set mode/owner/group on common module directories
    * Fix incorrect additional_settings documentation
    * Fix server_node_terminus behaviour under future parser
    * Fix generation of SSL certificates with restrictive umask
    * Fix default location of classes.txt to statedir
    * Do not set configtimeout under Puppet 4
    * Test under future parser and Puppet 4

## 3.0.0
* New or changed parameters:
    * Add additional_settings, agent_additional_settings and
      server_additional_settings parameters to manage miscellaneous main, agent
      and master configuration options respectively
    * Add ca_port parameter to change Puppet CA port
    * Add listen_to parameter to control auth.conf entries for kick/run
    * Add module_repository parameter to change puppet module server
    * Add prerun/postrun_command parameters to run command after Puppet run
    * Add puppetfactsource parameter, set default to work with SRV records
    * Add remove_lock parameter to control auto-enabling of Puppet agent
    * Add server_foreman parameter to control Foreman/Puppet master integration
    * Add server_puppetdb_* parameters for PuppetDB client configuration
    * Add server_parser parameter to change default Puppet parser
    * Add server_rack_arguments parameter to control Puppet master startup
    * Add server_request_timeout parameter to change Foreman ENC/report
      processor timeouts (#9286)
    * Add service_name parameter to override Puppet agent service name
    * Add owner, group, mode parameters to puppet::env
* Other features:
    * Make Foreman integration optional, no longer rely on foreman::params
    * theforeman/foreman module dependency is now optional, add it manually if
      you require Foreman integration (incompatible change)
    * theforeman/git module dependency optional, add it manually if enabling
      server_git_repo (incompatible change)
    * Add PuppetDB integration, configuring the master to send data to it
    * Add support for managing agent on FreeBSD
    * Add support for managing agent on Windows
    * Enable CRL checking for Apache 2.4 virtual host
* Other changes and fixes:
    * Improvements for Puppet 4 and future parser support
    * Manage mode on Rack application directories
    * Move directory env configuration to main section
    * Chain Foreman integration to ensure it refreshes the Puppet master
    * Fix config_version being set with directory envs, causing warning
    * Fix facts/receive_facts compatibility with theforeman/foreman 3.0.0
    * Fix puppetmaster variable definition under strict variables
    * Fix metadata quality, pin dependencies
    * Refreshed README

## 2.3.1
* Ensure that the Puppet master runs with UTF-8 locale under Rack (GH-196)

## 2.3.0
* Add server_implementation parameter to support Puppet Server
* Update SSL/TLS virtual host settings to latest recommendations
* Add syslogfacility parameter
* Add auth_allowed parameter
* Fix missing notify when Passenger is disabled (GH-183)
* Fix git warning shown by post-receive hook
* Fix order of git-shell installation for user shell
* Fix site.pp message to be clearer

## 2.2.1
* Fix relationship specification for early Puppet 2.7 releases

## 2.2.0
* Add support for directory environments, used by default on Puppet 3.6+
    * server_dynamic_environments is deprecated when
      server_directory_environments is enabled, set $server_environments = []
      instead for a similar effect
* Add puppetmaster parameter to override server setting
* Add server_environments_group and mode parameters for ownership of
  environments
* Add dns_alt_names parameter to add alternative DNS names to certs
* Add agent splaylimit and usecacheonfailure parameters
* Add hiera_config parameter
* Add use_srv_records, srv_domain and pluginsource parameters
* Masterless envs can set $runmode to 'none' to disable service and cron
* Fix SSL certificate/key filenames for uppercase hostnames (#6352)
* Ensure foreman_proxy service is refreshed after SSL certs change
* Fix stdin and stderr buffering in git post-receive hook
* Add error checking to git commands in git post-receive hook
* Typo fix in puppet.conf

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


\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
