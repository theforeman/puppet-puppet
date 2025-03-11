# frozen_string_literal: true

require 'spec_helper'

puppet_string = <<~PVERSION
Usage: puppet <subcommand> [options] <action> [options]

Available subcommands:

  Common:
    agent             The puppet agent daemon
    apply             Apply Puppet manifests locally
    config            Interact with Puppet's settings.
    help              Display Puppet help.
    lookup            Interactive Hiera lookup
    module            Creates, installs and searches for modules on the Puppet Forge.
    resource          The resource abstraction layer shell


  Specialized:
    catalog           Compile, save, view, and convert catalogs.
    describe          Display help about resource types
    device            Manage remote network devices
    doc               Generate Puppet references
    epp               Interact directly with the EPP template parser/renderer.
    facts             Retrieve and store facts.
    filebucket        Store and retrieve files in a filebucket
    generate          Generates Puppet code from Ruby definitions.
    node              View and manage node definitions.
    parser            Interact directly with the parser.
    plugin            Interact with the Puppet plugin system.
    script            Run a puppet manifests as a script without compiling a catalog
    ssl               Manage SSL keys and certificates for puppet SSL clients

See 'puppet help <subcommand> <action>' for help on a specific subcommand action.
See 'puppet help <subcommand>' for help on a specific subcommand.
Puppet v8.10.0
PVERSION

openvox_string = <<~OVERSION

Usage: puppet <subcommand> [options] <action> [options]

Available subcommands:

  Common:
    agent             The puppet agent daemon provided by OpenVox
    apply             Apply Puppet manifests locally via OpenVox
    config            Interact with OpenVox's settings.
    help              Display OpenVox help.
    lookup            Interactive Hiera lookup for OpenVox
    module            Creates, installs and searches for modules on the Puppet Forge.
    resource          The OpenVox resource abstraction layer shell


  Specialized:
    catalog           Compile, save, view, and convert catalogs.
    describe          Display help about resource types available to OpenVox
    device            Manage remote network devices via OpenVox
    doc               Generate Puppet references for OpenVox
    epp               Interact directly with the EPP template parser/renderer.
    facts             Retrieve and store facts.
    filebucket        Store and retrieve files in an OpenVox filebucket
    generate          Generates Puppet code from Ruby definitions.
    node              View and manage node definitions.
    parser            Interact directly with the parser.
    plugin            Interact with the OpenVox plugin system.
    script            Run a puppet manifests as a script without compiling a catalog
    ssl               Manage SSL keys and certificates for OpenVox SSL clients

See 'puppet help <subcommand> <action>' for help on a specific subcommand action.
See 'puppet help <subcommand>' for help on a specific subcommand.
OpenVox v8.13.0
OVERSION

describe Facter::Util::Fact.to_s do
  before { Facter.clear }
  context 'puppet not in path' do
    before do

      allow(Facter::Core::Execution).to receive(:which).with('puppet').and_return(false)
    end
    it { expect(Facter.fact(:puppet_flavor).value).to be_nil }
  end
  context 'puppet in path' do
    before do
      allow(Facter::Core::Execution).to receive(:which).with('puppet').and_return(true)
    end
    context 'with Perforce' do
      before do
        allow(Facter::Core::Execution).to receive(:execute).with('puppet --help') do
          puppet_string
        end
      end
      it { expect(Facter.fact(:puppet_flavor).value).to eq('Puppet') }
    end
    context 'with OpenVox' do
      before do
        allow(Facter::Core::Execution).to receive(:execute).with('puppet --help') do
          openvox_string
        end
      end
      it { expect(Facter.fact(:puppet_flavor).value).to eq('OpenVox') }
    end
  end
end
