
=head1 NAME

Rexfile - Rex task configuration for CPANTesters

=head1 SYNOPSIS

  # TODO

=head1 DESCRIPTION

This file defines all the L<Rex|http://rexify.org> tasks used to deploy
and configure the Kubernetes cluster for the CPANTesters servers.



=head1 SEE ALSO

L<Rex|http://rexify.org>

=cut

use Rex -feature => [ 1.4 ];
use Rex::Commands::Sync;
use Rex::Hardware;
use Term::ReadKey;
use File::Basename qw( basename );
use List::Util qw( uniq );
use HTTP::Tiny;
use JSON::PP;
use YAML::XS qw( Load Dump );
my $JSON = JSON::PP->new->ascii->pretty->canonical;

#######################################################################
# Groups
group servers => qw(
  'nact-pdx-001.cpantesters.org',
);
group nodes => qw(
  'osl-pdx-[001..002].cpantesters.org'
);

#######################################################################
# Settings

set common_packages_debian => [
  # Needed by Flannel
  qw( wireguard ),
  # Needed by Longhorn
  qw( open-iscsi nfs-common cryptsetup ),
];
set common_packages_rocky => [
  # Needed by Flannel
  qw( wireguard-tools ),
  # Needed by Longhorn
  qw( targetcli iscsi-initiator-utils ),
];

#######################################################################
# Environments
# TODO: It'd be kinda nice to be able to build a dev Kubernetes cluster
# using Vagrant to test things so we don't have to use production for
# testing.


#######################################################################
# Tasks

=head2 info

Print out the info for the machine, to be used in the CMDB.

=cut

desc 'Show host info';
task info =>
    sub {
      my %hw_info = Rex::Hardware->get('All');
      print Dump(\%hw_info);
    };

=head2 prepare

    rex prepare

Prepare a machine for a CPAN Testers role by installing common OS packages.
This will also, in the future, install firewalls, update security packages,
and other thing.

This task is run automatically by other prepare tasks like C<prepare_server>
or C<prepare_node>.

=cut

desc 'Prepare the machine for a CPANTesters role by installing OS packages';
task prepare =>
    sub {
        sudo sub {
            Rex::Logger::info( 'Fetching package lists' );
            update_package_db;

            Rex::Logger::info( "Checking common packages" );
            install package => $_ for @{ get 'common_packages' };

            Rex::Logger::info( "Adding sudo group to sudoers" );
            file '/etc/sudoers.d/sudo-group',
                owner => 'root',
                group => 'root',
                mode => '600', # u+rwx go-rwx
                content => '%sudo ALL=(ALL:ALL) ALL',
                ;

            Rex::Logger::info( "Adding `cpantesters` to sudo" );
            file '/etc/sudoers.d/cpantesters',
                owner => 'root',
                group => 'root',
                mode => '600', # u+rwx go-rwx
                content => "ALL ALL=(cpantesters) NOPASSWD: ALL\n%www-data ALL=(cpantesters) NOPASSWD: ALL",
                ;
        };
    };

=head2 prepare_server

    rex prepare_server

Prepare the machine to serve as a k3s server.

=cut

desc 'Prepare the machine to be a Kubernetes server';
task prepare =>
    sub {
        sudo sub {
            # TODO: Should install k3s and join the cluster as a server
        }
    };

=head2 prepare_node

    rex prepare_node

Prepare the machine to serve as a k3s node.

=cut

desc 'Prepare the machine to be a Kubernetes node';
task prepare =>
    sub {
        sudo sub {
            # TODO: Should install k3s and join the cluster as a node
        }
    };

