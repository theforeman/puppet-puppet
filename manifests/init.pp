class puppet {
  include puppet::params
  include puppet::install
  include puppet::config
}
