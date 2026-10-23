# Set up the ENC config
# @api private
class puppet::server::enc (
  Variant[Undef, String[0], Stdlib::Absolutepath] $enc_path = $puppet::server::external_nodes,
  Enum['plain', 'exec', 'classifier'] $node_terminus = $puppet::server::node_terminus,
) {
  if $enc_path and $enc_path != '' {
    puppet::config::server {
      'external_nodes':     value => $enc_path;
      'node_terminus':      value => $node_terminus;
    }
  }
  else {
    puppet::config::server {
      'node_terminus':      value => $node_terminus;
    }
  }
}
