
=head1 NAME

Rexfile - Rex task configuration for CPANTesters

=head1 SYNOPSIS

    # Prepare an API server
    rex -E <env> prepare_api

=head1 DESCRIPTION

This file defines all the L<Rex|http://rexify.org> tasks used to deploy
and configure the CPANTesters servers.

=head1 SEE ALSO

L<Rex|http://rexify.org>

=cut

use Rex -feature => [ 1.4 ];
use Rex::Commands::Sync;
use Term::ReadKey;
use File::Basename qw( basename );

#######################################################################
# Groups
group api => 'cpantesters3.dh.bytemark.co.uk';
group monitor => 'monitor.preaction.me';

#######################################################################
# Settings

set perl_version => '5.24.0';
set perlbrew_root => '/opt/local/perlbrew';

set common_packages => [ qw/
    build-essential git perl-doc perl vim logrotate ack-grep
/ ];
set api_packages => [qw/ apache2 runit perlbrew libmysqlclient-dev /];

#######################################################################
# Environments
# The Vagrant VM for development purposes
environment vm => sub {
    group api => '192.168.127.127'; # the Vagrant VM IP
    group monitor => '192.168.127.127';
    set 'no_sudo_password' => 1;
    user 'vagrant';
    # XXX: Does this only work with virtualbox?
    private_key '.vagrant/machines/default/virtualbox/private_key';
};

#######################################################################
# Tasks

=head2 prepare

    rex -g api prepare

Prepare a machine for a CPAN Testers role by installing common OS packages.
This will also, in the future, install firewalls, update security packages,
and other thing.

This task is run automatically by other prepare tasks like C<prepare_api>.

=cut

desc 'Prepare the machine for a CPANTesters role by installing OS packages';
task prepare =>
    sub {
        ensure_sudo_password();

        Rex::Logger::info( "Checking common packages" );
        sudo sub {
            install package => $_ for @{ get 'common_packages' };
            Rex::Logger::info( "Enabling mod_rewrite for /etc/cpantesters.org.conf" );
            run 'a2enmod rewrite';
            service apache2 => 'restart';
        };
    };

=head2 prepare_api

    rex prepare_api

Prepare a machine to run the CPAN Testers API by installing OS-level
package requirements (L</prepare>), setting up Perl (L</prepare_perl>),
and setting up a user account (L</prepare_user>).

=cut

desc 'Prepare the machine to run the CPAN Testers API';
task prepare_api =>
    group => [qw( api )],
    sub {

        run_task 'prepare', on => connection->server;

        ensure_sudo_password();
        sudo sub {
            Rex::Logger::info( "Checking API packages" );
            install package => $_ for @{ get 'api_packages' };

            Rex::Logger::info( "Disabling system runit" );
            run 'systemctl stop runit';
            run 'systemctl disable runit';

            Rex::Logger::info( "Installing reverse proxy for api.cpantesters.org" );
            run 'a2enmod ' . $_ for qw( proxy proxy_http proxy_wstunnel );
            file '/etc/apache2/sites-available/api.cpantesters.org.conf',
                source => 'etc/apache2/vhost/api.cpantesters.org.conf';
            run 'a2ensite api.cpantesters.org';
            run 'a2dissite 000-default';
            service apache2 => 'restart';
        };

        run_task 'prepare_perl', on => connection->server;
        run_task 'prepare_user', on => connection->server;
    };

=head2 prepare_perl

    rex -g api prepare_perl

Install L<perlbrew|http://perlbrew.pl>, install the right Perl version
and install any other prereqs to ensure a proper, working Perl
environment. This task is run automatically by other prepare tasks like
C<prepare_api>.

=cut

desc 'Deploy Perl to the server using perlbrew';
task prepare_perl =>
    sub {
        my $root = get 'perlbrew_root';
        my $perl_version = get 'perl_version';
        my %env = (
            env => { PERLBREW_ROOT => $root }
        );

        ensure_sudo_password();

        sudo sub {
            pkg 'perlbrew', ensure => 'present';
            file $root, ensure => 'directory';
            run 'perlbrew init', %env;
            my @versions = run 'perlbrew list', %env;
            Rex::Logger::info( "Installed perls: @versions" );
            if ( !grep { /$perl_version$/ } @versions ) {
                Rex::Logger::info( 'Installing Perl ' . $perl_version );
                run 'perlbrew install ' . $perl_version, %env;
            }
            run 'perlbrew install-cpanm', %env;
            run 'perlbrew exec cpanm local::lib', %env;
        };
    };

=head2 prepare_user

    rex prepare_user

Prepare a C<cpantesters> user in the given host. Also sets up a local
SSH key to use to log in as the C<cpantesters> user (saved in
C<~/.ssh/cpantesters-rex>). This key is used by all CPAN Testers
Rexfiles to deploy apps and perform tasks. This task is run
automatically by other prepare tasks like C<prepare_api>.

=cut

desc 'Set up a local cpantesters user';
task prepare_user =>
    sub {
        my $ssh_key;
        my $perl_version = get 'perl_version';
        my $perlbrew_root = get 'perlbrew_root';

        LOCAL {
            if ( !-e glob '~/.ssh/cpantesters-rex' ) {
                Rex::Logger::info( 'Generating new cpantesters-rex key in ~/.ssh' );
                run 'ssh-keygen -q -N "" -t ecdsa -f ~/.ssh/cpantesters-rex';
                run 'chmod go-rwx ~/.ssh/cpantesters-rex{,.pub}';
            }
            $ssh_key = cat '~/.ssh/cpantesters-rex.pub';
        };

        ensure_sudo_password();
        sudo sub {
            account cpantesters =>
                ensure => 'present',
                comment => 'CPAN Testers application account',
                crypt_password => '*', # Disable passwords
                shell => '/bin/bash',
                create_home => TRUE;

            Rex::Logger::info( 'Appending your cpantesters-rex ssh key' );
            file '/home/cpantesters/.ssh',
                ensure => 'directory',
                owner => 'cpantesters',
                group => 'cpantesters',
                mode => '700', # u+rwx go-rwx
                ;
            file '/home/cpantesters/.ssh/authorized_keys',
                ensure => 'exists',
                owner => 'cpantesters',
                group => 'cpantesters',
                mode => '700', # u+rwx go-rwx
                ;

            append_if_no_such_line '/home/cpantesters/.ssh/authorized_keys',
                $ssh_key;

            Rex::Logger::info( 'Setting up user environment' );
            file '/home/cpantesters/.profile',
                source => 'etc/profile';

            Rex::Logger::info( 'Enabling Perl' );
            run 'sudo -i -u cpantesters PERLBREW_ROOT=' . $perlbrew_root . ' perlbrew switch perl-' . $perl_version;

            Rex::Logger::info( 'Adding database configuration' );
            file '/home/cpantesters/.cpanstats.cnf',
                owner => 'cpantesters',
                group => 'cpantesters',
                mode => '600',
                source => 'etc/cpanstats.cnf';

            Rex::Logger::info( 'Adding service/ directory' );
            file '/home/cpantesters/service',
                ensure => 'directory',
                owner => 'cpantesters',
                group => 'cpantesters',
                ;
            sync_up 'etc/systemd', '/etc/systemd/system', {
                files => {
                    mode => 664,
                },
            };
            run 'systemctl enable runsvdir';
            run 'systemctl start runsvdir';
        };
    };

=head2 prepare_monitor

    rex prepare_monitor

Prepare the server for the monitoring packages.

=cut

desc 'Prepare server to be a monitor';
task prepare_monitor =>
    group => [qw( monitor )],
    sub {
        ensure_sudo_password();
        sudo sub {
            Rex::Logger::info( 'Enabling backports' );
            repository add => "backports",
                url => 'http://ftp.debian.org/debian',
                distro => 'jessie-backports',
                repository => 'main';
            pkg 'apt-transport-https', ensure => "present";

            Rex::Logger::info( 'Enabling Grafana packages' );
            repository add => "grafana",
                url => 'https://packagecloud.io/grafana/stable/debian/',
                key_url => 'https://packagecloud.io/gpg.key',
                distro => 'jessie',
                repository => 'main';
            update_package_db;

            Rex::Logger::info( 'Installing Grafana' );
            pkg 'grafana', ensure => "present";
            service 'grafana-server', ensure => 'started';
        };
    };

#######################################################################

=head1 Subroutines

=head2 ensure_sudo_password

Ensure a C<sudo> password is set. Use this at the start of any task
that requires C<sudo>.

=cut

sub ensure_sudo_password {
    return if sudo_password();
    return if get 'no_sudo_password';
    print 'Password to use for sudo: ';
    ReadMode('noecho');
    sudo_password ReadLine(0);
    ReadMode('restore');
    print "\n";
}

