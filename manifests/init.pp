class puppet {
  include puppet::params
  include puppet::install
  include puppet::config

  case $puppet::params::run_style {
    'cron': { include puppet::cron }
    'daemon': { include puppet::daemon }
    default: { }
  }
}
