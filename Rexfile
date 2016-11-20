
=head1 NAME

Rexfile - Rex task configuration for CPANTesters

=head1 SYNOPSIS

    # Prepare an API server
    rex prepare
    rex prepare_api
    rex prepare_perl
    rex prepare_user

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

#######################################################################
# Settings

set perl_version => '5.24.0';
set perlbrew_root => '/opt/local/perlbrew';

set common_packages => [ qw/
    build-essential git perl-doc perl vim logrotate ack-grep
/ ];
set api_packages => [qw/ perlbrew libmysqlclient-dev /];

#######################################################################
# Environments
# The Vagrant VM for development purposes
environment vm => sub {
    group api => '192.168.127.127'; # the Vagrant VM IP
    set 'no_sudo_password' => 1;
    user 'vagrant';
    # XXX: Does this only work with virtualbox?
    private_key '.vagrant/machines/default/virtualbox/private_key';
};

#######################################################################
# Tasks

desc 'Prepare the machine for a CPANTesters role by installing OS packages';
task prepare =>
    sub {
        ensure_sudo_password();

        Rex::Logger::info( "Checking common packages" );
        sudo sub {
            install package => $_ for @{ get 'common_packages' };
        };
    };

desc 'Prepare the machine to run the CPAN Testers API';
task prepare_api =>
    sub {
        ensure_sudo_password();

        Rex::Logger::info( "Checking API packages" );
        sudo sub {
            install package => $_ for @{ get 'api_packages' };
        };
    };

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
            Rex::Logger::info( 'Installing Perl ' . $perl_version );
            run 'perlbrew install ' . $perl_version, %env;
            run 'perlbrew install-cpanm', %env;
            run 'perlbrew exec cpanm local::lib', %env;
        };
    };

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
                source => 'home/profile';
            file '/home/cpantesters/.bash_profile',
                content => 'source ~/.profile';

            Rex::Logger::info( 'Enabling Perl' );
            run 'sudo -i -u cpantesters PERLBREW_ROOT=' . $perlbrew_root . ' perlbrew switch perl-' . $perl_version;

            Rex::Logger::info( 'Adding database configuration' );
            file '/home/cpantesters/.cpanstats.cnf',
                owner => 'cpantesters',
                group => 'cpantesters',
                mode => '600',
                source => 'etc/cpanstats.cnf';
        };
    };

#######################################################################
# Subroutines

sub ensure_sudo_password {
    return if sudo_password();
    return if get 'no_sudo_password';
    print 'Password to use for sudo: ';
    ReadMode('noecho');
    sudo_password ReadLine(0);
    ReadMode('restore');
    print "\n";
}

