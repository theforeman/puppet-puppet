# Set up the ENC config
#
# @summary Configures External Node Classifier (ENC) for Puppet Server
#
# This class configures the puppet server to use an external node classifier
# script for node classification instead of the default manifest-based approach.
#
# @param enc_path
#   The path to the external node classifier script. Can be undef to disable,
#   an empty string, or an absolute path to the ENC script.
#
# @api private
class puppet::server::enc (
  Variant[Undef, String[0], Stdlib::Absolutepath] $enc_path = $puppet::server::external_nodes
) {
  puppet::config::server {
    'external_nodes':     value => $enc_path;
    'node_terminus':      value => 'exec';
  }
}
