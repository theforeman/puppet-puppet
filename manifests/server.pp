class puppet::server {
  include puppet::server::install
  include puppet::server::config
}
