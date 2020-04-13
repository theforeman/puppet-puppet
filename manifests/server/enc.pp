# Set up the ENC config
# @api private
class puppet::server::enc(
  $enc_path = $puppet::server::external_nodes
) {
  puppet::config::master {
    'external_nodes':     value => $enc_path;
    'node_terminus':      value => 'exec';
  }
}
