# Set up the ENC config
# @api private
class puppet::server::enc (
  Variant[Undef, String[0], Stdlib::Absolutepath] $enc_path = $puppet::server::external_nodes
) {
  puppet::config::server {
    'external_nodes':     value => $enc_path;
    'node_terminus':      value => 'exec';
  }
}
