
=head1 NAME

Rexfile - Rex task configuration for CPANTesters

=head1 SYNOPSIS

    # Prepare an API server
    rex -E <env> prepare_api

=head1 DESCRIPTION

This file defines all the L<Rex|http://rexify.org> tasks used to deploy
and configure the CPANTesters servers.

=head2 Roles

A single machine can take on multiple roles. Each role has
a corresponding C<prepare_*> task to prepare the machine for that role.
Most roles' main installation is done in another repository, listed with
the roles below.

Everything that requires a root account to perform (installing packages,
creating users, running daemons on ports < 1024) is done by this Rexfile
so that other Rexfiles can be done with lower privileges.

=over 4

=item database

The C<database> role is for a database server. This will install the
database and set up a database user that can deploy the schema. The
database user is set up to allow access from the C<api>, C<backend>, and
C<web> servers (which may all be the same server).

The database schema is deployed by L<the CPAN::Testers::Schema
Rexfile|http://github.com/cpan-testers/cpantesters-schema>.

=item api

The C<api> role is for the API server. The API server hosts the REST API
and the message broker for real-time communication between the backend
components. This task installs the Apache 2.4 HTTPD and sets up the
reverse proxy to the Mojolicious API application.

The C<prepare_api> task prepares a machine for an API role.

The API daemons are deployed by L<the CPAN::Testers::API
Rexfile|http://github.com/cpan-testers/cpantesters-api>.

=item backend

The C<backend> role prepares a server as a backend processing machine.
These machines will join the job processing cluster and run periodic
cron jobs to process incoming data into useful forms.

The backend daemons and jobs are deployed by L<the
CPAN::Testers::Backend
Rexfile|http://github.com/cpan-testers/cpantesters-backend>.

=item cpan

The C<cpan> role prepares a server to be used as a CPAN/BackPAN mirror.

=item web

The C<web> role prepares a server to host the main CPAN Testers website,
L<http://cpantesters.org>.  The web role installs the Apache 2.4 HTTPD
and sets up the reverse proxy needed to access the main Mojolicious web
application.

XXX: The C<prepare_web> task is not completed

The main web application is deployed by L<the
CPAN::Testers::Web
Rexfile|http://github.com/cpan-testers/cpantesters-web>.

=item monitor

The C<monitor> role prepares a server to monitor the rest of the
network.  This installs monitoring packages and configures the alerting
so that admins are notified when services are unavailable.

XXX: Monitoring packages are installed but no monitors are configured

This role does not have any other repository to worry about.

=back

=head1 SEE ALSO

L<Rex|http://rexify.org>

=cut

use Rex -feature => [ 1.4 ];
use Rex::Commands::Sync;
use Term::ReadKey;
use File::Basename qw( basename );
use List::Util qw( uniq );
use HTTP::Tiny;
use JSON::PP;
my $JSON = JSON::PP->new->ascii->pretty->canonical;

#######################################################################
# Groups
group all => qw(
    cpantesters3.dh.bytemark.co.uk cpantesters4.dh.bytemark.co.uk
    monitor.preaction.me
);
group api => qw( cpantesters3.dh.bytemark.co.uk cpantesters4.dh.bytemark.co.uk );
group backend => 'cpantesters4.dh.bytemark.co.uk';
group web => 'cpantesters3.dh.bytemark.co.uk';
group monitor => 'monitor.preaction.me';
group legacy => 'cpantesters3.dh.bytemark.co.uk';
group cpan => 'cpantesters4.dh.bytemark.co.uk';

# The prod database is _not_ accessible via SSH from the outside world
#group database => '216.246.80.45';
#group database => '216.246.80.46';
group database => 'db-primary-1.cpantesters.org';

#######################################################################
# Settings

set perl_version => '5.24.0';
set perlbrew_root => '/opt/local/perlbrew';

set common_packages => [ qw/
    build-essential git perl-doc perl vim logrotate ack-grep ntp sudo rsync
    less tmux strace screen
/ ];

my @web_packages = qw/ apache2 runit perlbrew default-libmysqlclient-dev /;
set api_packages => \@web_packages;
set backend_packages => [qw/ runit perlbrew default-libmysqlclient-dev / ];
set cpan_packages => [qw/ runit perlbrew apache2 / ];

set database_host => '216.246.80.46';
set database_name => 'cpanstats';
set database_user => 'cpantesters';
set database_password => 'Md5syMxdsKcf6n6eK';

set monitor_host => 'status.cpantesters.org';
set monitor_port => '3000';
set monitor_user => 'admin';
set monitor_password => 'YKn-sfS-a3U-KFs';
set monitor_mysql_user => 'monitor';
set monitor_mysql_password => 'fQZsTa6nvS83zjX';
set monitor_mysql_hosts => [qw( db-primary-1.cpantesters.org db-replica-1.cpantesters.org )];

my %sites = (
    api => [qw( api.cpantesters.org metabase.cpantesters.org )],
    www => [qw( beta.cpantesters.org cpantesters.org )],
    monitor => [qw( status.cpantesters.org )],
    cpan => [qw( cpan.cpantesters.org backpan.cpantesters.org )],
    downtime => [qw( 000-maintenance )],
);

my @grafana_dashboards = (qw(
    Reports
    Web-DB
));

#######################################################################
# Environments
# The Vagrant VM for development purposes
environment vm => sub {
    group api => '192.168.127.127'; # the Vagrant VM IP
    group monitor => '192.168.127.127';
    group database => '192.168.127.127';
    group backend => '192.168.127.127';
    group web => '192.168.127.127';
    group cpan => '192.168.127.127';
    set 'no_sudo_password' => 1;
    set database_host => '127.0.0.1';
    set monitor_host => '192.168.127.127';
    set monitor_user => 'admin';
    set monitor_password => 'admin';
    set monitor_mysql_user => get 'database_user';
    set monitor_mysql_password => get 'database_password';
    set monitor_mysql_hosts => [qw( 127.0.0.1 )];
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

        sudo sub {
            Rex::Logger::info( 'Fetching package lists' );
            update_package_db;

            Rex::Logger::info( "Checking common packages" );
            install package => $_ for @{ get 'common_packages' };

            Rex::Logger::info( "Adding `cpantesters` to sudo" );
            append_if_no_such_line '/etc/sudoers',
                'ALL ALL=(cpantesters) NOPASSWD: ALL';
        };
    };

=head2 prepare_api

    rex prepare_api

Prepare a machine to run the CPAN Testers API by installing OS-level
package requirements (L</prepare>), setting up Perl (L</prepare_perl>),
and setting up a user account (L</prepare_user>).

Once the machine is prepared, you can run the C<deploy> task from the
L<cpantesters-api|http://github.com/cpan-testers/cpantesters-api/>
C<Rexfile>.

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

            run 'a2enmod ' . $_ for qw( proxy proxy_http proxy_wstunnel rewrite );

            _deploy_include_files();
            _deploy_group_sites( "api" );
        };

        run_task 'prepare_perl', on => connection->server;
        run_task 'prepare_user', on => connection->server;
    };

=head2 prepare_backend

    rex prepare_backend

Prepare a machine to run the CPAN Testers Backend by installing OS-level
package requirements (L</prepare>), setting up Perl (L</prepare_perl>),
setting up a user account (L</prepare_user>), and setting up
CPAN/BackPAN mirroring (L</prepare_cpan>).

Once the machine is prepared, you can run the C<deploy> task from the
L<cpantesters-backend|http://github.com/cpan-testers/cpantesters-backend/>
C<Rexfile>.

=cut

desc 'Prepare the machine to run the CPAN Testers Backend';
task prepare_backend =>
    group => [qw( backend )],
    sub {

        run_task 'prepare', on => connection->server;

        ensure_sudo_password();
        sudo sub {
            Rex::Logger::info( "Checking Backend packages" );
            install package => $_ for @{ get 'backend_packages' };

            Rex::Logger::info( "Disabling system runit" );
            run 'systemctl stop runit';
            run 'systemctl disable runit';
        };

        run_task 'prepare_perl', on => connection->server;
        run_task 'prepare_user', on => connection->server;
    };

desc 'Prepare the machine as a CPAN/BackPAN mirror';
task prepare_cpan =>
    group => [qw( cpan )],
    sub {
        run_task 'prepare', on => connection->server;
        run_task 'prepare_perl', on => connection->server;

        my $perl_version = get 'perl_version';
        my $perlbrew_root = get 'perlbrew_root';

        sudo sub {
            Rex::Logger::info( "Checking CPAN packages" );
            install package => $_ for @{ get 'cpan_packages' };

            Rex::Logger::info( 'Creating CPAN user' );
            account cpan =>
                ensure => 'present',
                comment => 'CPAN mirror account',
                crypt_password => '*', # Disable passwords
                shell => '/bin/bash',
                create_home => TRUE;

            Rex::Logger::info( 'Allowing sudo to `cpan` for everyone' );
            append_if_no_such_line '/etc/sudoers',
                'ALL ALL=(cpan) NOPASSWD: ALL';

            Rex::Logger::info( 'Setting up cpan user environment' );
            for my $file ( qw( .profile .bash_profile ) ) {
                file '/home/cpan/' . $file,
                    content => template( 'etc/profile.tpl' ),
                    owner => 'cpan',
                    group => 'cpan',
                    mode => '600',
                    ;
            }

            Rex::Logger::info( 'Enabling Perl' );
            run 'sudo -i -u cpan PERLBREW_ROOT=' . $perlbrew_root . ' perlbrew switch perl-' . $perl_version;

            Rex::Logger::info( 'Adding service/ directory' );
            file '/home/cpan/service',
                ensure => 'directory',
                owner => 'cpan',
                group => 'cpan',
                ;
            file '/etc/systemd/system/runsvdir-cpan.service',
                source => 'etc/systemd/runsvdir-cpan.service',
                mode => 644,
                owner => 'root',
                group => 'root',
                ;
            run 'systemctl enable runsvdir-cpan';
            run 'systemctl start runsvdir-cpan';

            Rex::Logger::info( 'Setting up rsync server' );
            file '/etc/rsyncd.conf', source => 'etc/rsyncd.conf';
            run 'systemctl enable rsync';
            run 'systemctl start rsync';

            Rex::Logger::info( 'Preparing crontab environment' );
            run 'crontab -u cpan -l || echo "" | crontab -u cpan -';
            cron env => 'cpan' => add => {
                PERL5LIB => '/home/cpan/perl5/lib/perl5',
                PATH => '/home/cpan/bin:/home/cpan/perl5/bin:/opt/local/perlbrew/bin:/opt/local/perlbrew/perls/perl-5.24.0/bin:/usr/local/bin:/usr/bin:/bin',
                MAILTO => 'doug@preaction.me',
            };

            # Install CPAN mirroring client
            Rex::Logger::info( 'Installing CPAN mirroring client (rrr-client)' );
            run 'sudo -u cpan bash -c "source ~/.profile && cpanm JSON File::Rsync::Mirror::Recent BackPAN::Index::Create"';
            if ( $? ) {
                say last_command_output;
            }
            file '/home/cpan/CPAN',
                ensure => 'directory',
                owner => 'cpan',
                group => 'cpan',
                ;
            file '/home/cpan/BACKPAN',
                ensure => 'directory',
                owner => 'cpan',
                group => 'cpan',
                ;

            Rex::Logger::info( 'Adding service files to sync CPAN' );
            file '/home/cpan/service/rrr-client',
                ensure => 'directory',
                owner => 'cpan',
                group => 'cpan',
                ;
            file '/home/cpan/service/rrr-client/log',
                ensure => 'directory',
                owner => 'cpan',
                group => 'cpan',
                ;
            file '/home/cpan/service/rrr-client/run',
                source => 'etc/runit/rrr-client/run',
                owner => 'cpan',
                group => 'cpan',
                mode => 755,
                ;
            file '/home/cpan/service/rrr-client/log/run',
                source => 'etc/runit/rrr-client/log/run',
                owner => 'cpan',
                group => 'cpan',
                mode => 755,
                ;
            run 'sudo -u cpan sv start /home/cpan/service/rrr-client';

            Rex::Logger::info( 'Adding BackPAN mirror scripts' );
            file '/home/cpan/var/log',
                ensure => 'directory',
                owner => 'cpan',
                group => 'cpan',
                ;
            file '/home/cpan/var/run',
                ensure => 'directory',
                owner => 'cpan',
                group => 'cpan',
                ;
            file '/home/cpan/bin',
                ensure => 'directory',
                owner => 'cpan',
                group => 'cpan',
                ;
            file '/home/cpan/bin/backpan.sh',
                source => 'bin/backpan.sh',
                owner => 'cpan',
                group => 'cpan',
                mode => 755,
                ;
            cron_entry 'backpan',
                user => 'cpan',
                minute => 50,
                hour => '*',
                day_of_month => '*',
                month => '*',
                day_of_week => '*',
                ensure => 'present',
                command => 'backpan.sh',
                ;

            Rex::Logger::info( 'Configuring Apache2' );
            _deploy_include_files();
            _deploy_group_sites( 'cpan' );

            Rex::Logger::info( 'Configuring logrotate' );
            file '/etc/logrotate.d/cpan',
                source => 'etc/logrotate-cpan.conf',
                owner => 'root',
                group => 'root',
                mode => 644,
                ;
        };

    };

task deploy_cpan => group => [qw( cpan )], sub {
    ensure_sudo_password();
    sudo sub {
        Rex::Logger::info( 'Configuring Apache2' );
        _deploy_include_files();
        _deploy_group_sites( 'cpan' );
    };
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
            for my $file ( qw( .profile .bash_profile ) ) {
                file '/home/cpantesters/' . $file,
                    content => template( 'etc/profile.tpl' ),
                    owner => 'cpantesters',
                    group => 'cpantesters',
                    mode => '600',
                    ;
            }

            Rex::Logger::info( 'Enabling Perl' );
            run 'sudo -i -u cpantesters PERLBREW_ROOT=' . $perlbrew_root . ' perlbrew switch perl-' . $perl_version;

            Rex::Logger::info( 'Adding database configuration' );
            file '/home/cpantesters/.cpanstats.cnf',
                owner => 'cpantesters',
                group => 'cpantesters',
                mode => '600',
                content => template( 'etc/cpanstats.cnf.tpl',
                    ( map { $_ => get "database_$_" } qw( host user name password ) ),
                );

            Rex::Logger::info( 'Adding service/ directory' );
            file '/home/cpantesters/service',
                ensure => 'directory',
                owner => 'cpantesters',
                group => 'cpantesters',
                ;
            file '/etc/systemd/system/runsvdir.service',
                source => 'etc/systemd/runsvdir.service',
                mode => 644,
                owner => 'root',
                group => 'root',
                ;
            run 'systemctl enable runsvdir';
            run 'systemctl start runsvdir';

            Rex::Logger::info( 'Preparing crontab environment' );
            run 'crontab -u cpantesters -l || echo "" | crontab -u cpantesters -';
            cron env => 'cpantesters' => add => {
                PERL5LIB => '/home/cpantesters/perl5/lib/perl5',
                PATH => '/home/cpantesters/perl5/bin:/opt/local/perlbrew/bin:/opt/local/perlbrew/perls/perl-5.24.0/bin:/usr/local/bin:/usr/bin:/bin',
                MAILTO => 'doug@preaction.me',
            };

            Rex::Logger::info( 'Configuring logrotate' );
            file '/etc/logrotate.d/cpantesters',
                source => 'etc/logrotate-cpantesters.conf',
                owner => 'root',
                group => 'root',
                mode => 644,
                ;
            file '/home/cpantesters/var/log',
                ensure => 'directory',
                owner => 'cpantesters',
                group => 'cpantesters',
                ;
        };
    };

=head2 add_user

    rex add_user --user=<user> [--root=1]

Add a user account to the given box. The user will be given sudo access to the
C<cpantesters> user. If the C<--root> option is given, the user will be given
full sudo privileges.

=cut

task add_user =>
    group => [qw( all )],
    sub {
        my ( $opt ) = @_;
        my ( $user, $root ) = @{$opt}{qw( user root )};
        if ( !$user ) {
            die "User is required";
        }
        ensure_sudo_password();
        sudo sub {
            create_user(
                $user,
                password => '123qwe',
                shell => '/bin/bash',
                create_home => TRUE,
            );
            if ( $root ) {
                append_if_no_such_line '/etc/sudoers',
                    "$user ALL=(ALL:ALL) ALL";
            }
        };
    };

=head2 remove_user

    rex remove_user --user=<user>

Remove a user account from the given box.

=cut

task remove_user =>
    group => [qw( all )],
    sub {
        my ( $opt ) = @_;
        my ( $user ) = @{$opt}{qw( user )};
        if ( !$user ) {
            die "User is required";
        }
        delete_user( $user =>
            delete_home => TRUE,
        );
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

            Rex::Logger::info( 'Enabling fluentd packages' );
            repository add => 'fluentd',
                key_url => 'https://packages.treasuredata.com/GPG-KEY-td-agent',
                url => 'http://packages.treasuredata.com/2/debian/jessie/',
                distro => 'jessie',
                repository => 'contrib',
                ;

            Rex::Logger::info( 'Enabling InfluxDB packages' );
            repository add => 'influxdb',
                key_url => 'https://repos.influxdata.com/influxdb.key',
                url => 'https://repos.influxdata.com/debian',
                distro => 'jessie',
                repository => 'stable',
                ;

            Rex::Logger::info( 'Fetching package lists' );
            update_package_db;

            Rex::Logger::info( 'Ensuring postfix is installed' );
            pkg 'postfix', ensure => "present";

            Rex::Logger::info( 'Ensuring Grafana is installed' );
            pkg 'grafana', ensure => "present";

            Rex::Logger::info( 'Ensuring Fluentd is installed' );
            pkg 'td-agent', ensure => 'present';

            Rex::Logger::info( 'Ensuring InfluxDB is installed' );
            pkg 'influxdb', ensure => 'present';

            Rex::Logger::info( 'Ensuring Telegraf is installed' );
            pkg 'telegraf', ensure => 'present';

            Rex::Logger::info( 'Ensuring Apache is installed' );
            pkg 'apache2', ensure => 'present';

            Rex::Logger::info( 'Configuring postfix for local-only mail' );
            append_or_amend_line '/etc/postfix/main.cf',
                regexp => qr{^\s*inet_interfaces\s*=},
                line  => 'inet_interfaces = 127.0.0.1',
                on_change => sub { service postfix => 'stop' };
            append_or_amend_line '/etc/postfix/main.cf',
                regexp => qr{^\s*smtpd_use_tls\s*=},
                line  => 'smtpd_use_tls=no',
                on_change => sub { service postfix => 'stop' };

            Rex::Logger::info( 'Configuring telegraf' );
            file '/etc/telegraf/telegraf.d/http.conf',
                owner => 'root',
                group => 'root',
                mode => '666',
                source => 'etc/telegraf/http.conf',
                on_change => sub { service telegraf => 'stop' },
                ;
            file '/etc/telegraf/telegraf.d/mysql.conf',
                owner => 'root',
                group => 'root',
                mode => '666',
                content => template( 'etc/telegraf/mysql.conf.tpl',
                    servers => q{"} . (
                        join q{","}, map {
                            get( 'monitor_mysql_user' ) . ':' . get( 'monitor_mysql_password' )
                            . '@tcp(' . $_ . ':3306)/?tls=false'
                        } @{ get 'monitor_mysql_hosts' }
                    ) . q{"},
                ),
                on_change => sub { service telegraf => 'stop' },
                ;


            Rex::Logger::info( 'Configuring grafana' );
            file '/etc/grafana/grafana.ini',
                owner => 'root',
                group => 'grafana',
                mode => '640',
                content => template( 'etc/grafana/grafana.ini.tpl',
                    ( map {; $_ => get "monitor_$_" } qw( host user name password ) ),
                ),
                on_change => sub { service 'grafana-server' => 'stop' },
                ;

            Rex::Logger::info( 'Enabling Apache modules' );
            run 'a2enmod ' . $_ for qw( proxy proxy_http proxy_wstunnel rewrite );

            Rex::Logger::info( 'Configuring Apache' );
            _deploy_include_files();
            _deploy_group_sites( 'monitor' );

            Rex::Logger::info( 'Syncing Apache site' );
            file '/var/www/status',
                ensure => 'directory',
                owner => 'www-data',
                group => 'www-data',
                mode => '775', # u+rwx go-rwx
                ;
            sync_up 'var/www/status', '/var/www/status';

            Rex::Logger::info( 'Starting services' );
            service 'postfix', ensure => 'started';
            service 'grafana-server', ensure => 'started';
            service 'td-agent', ensure => 'started';
            service 'influxdb', ensure => 'started';
            service 'telegraf', ensure => 'started';
            service 'apache2', ensure => 'started';

            Rex::Logger::info( 'Preparing user profile for Perl' );
            for my $file ( qw( .profile .bash_profile ) ) {
                file '~/' . $file,
                    content => template( 'etc/profile.tpl' ),
                    owner => 'root',
                    group => 'root',
                    mode => '644',
                    ;
            }

            Rex::Logger::info( 'Installing Yertl' );
            run 'source ~/.profile; cpan ETL::Yertl@0.34';

            Rex::Logger::info( 'Configuring Yertl' );
            my $dbname = get 'database_name';
            my $dbhost = get 'database_host';
            my $dbuser = get 'monitor_mysql_user';
            my $dbpass = get 'monitor_mysql_password';
            run "source ~/.profile; ysql --config mysql --driver mysql --database $dbname --host $dbhost --user $dbuser --password $dbpass";

            Rex::Logger::info( 'Configuring Cron Jobs' );
            run 'crontab -u root -l || echo "" | crontab -u root -';
            cron env => 'root' => add => {
                MAILTO => 'doug@preaction.me',
                PERL5LIB => '/root/perl5/lib/perl5',
                PATH => '/root/perl5/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
                HOME => '/root',
            };

            my %metrics = (
                '*' => {
                    "telegraf.minion.total_jobs" => q{--count minion_jobs},
                    "telegraf.minion.inactive_jobs" => q{--count minion_jobs --where 'state="inactive"'},
                    "telegraf.minion.finished_jobs" => q{--count minion_jobs --where 'state="finished"'},
                    "telegraf.minion.failed_jobs" => q{--count minion_jobs --where 'state="failed"'},
                },
                5 => {
                    "telegraf.cpantesters.report_count" => q{--count test_report},
                    "telegraf.cpantesters.stats_count" => q{--count cpanstats},
                },
            );
            for my $time ( keys %metrics ) {
                my $minute = $time eq '*' ? '*' : '*/' . $time;
                for my $metric ( keys %{ $metrics{ $time } } ) {
                    my $ysql = "ysql mysql $metrics{ $time }{ $metric }";
                    my $yts = "yts influxdb://localhost $metric";
                    cron_entry $metric,
                        user => 'root',
                        minute => $minute,
                        hour => '*',
                        day_of_month => '*',
                        month => '*',
                        day_of_week => '*',
                        ensure => 'present',
                        command => "$ysql | $yts",
                        ;
                }
            }
        };
    };

=head2 prepare_database

    rex prepare_database

Prepare the server to host the MySQL database

=cut

desc 'Prepare server to host a database';
task prepare_database =>
    group => [qw( database )],
    sub {
        ensure_sudo_password();
        sudo sub {
            Rex::Logger::info( 'Setting up MySQL APT Repo' );
            run 'apt-key adv --keyserver pgp.mit.edu --recv-keys 5072E1F5';
            file '/etc/apt/sources.list.d/mysql.list',
                content => 'deb http://repo.mysql.com/apt/debian/ jessie mysql-5.7',
                ;
            update_package_db;

            Rex::Logger::info( 'Enabling database' );
            pkg 'mysql-server', ensure => 'present';

            Rex::Logger::info( 'Configuring database' );
            append_if_no_such_line '/etc/mysql/mysql.conf.d/mysqld.cnf',
                'skip-name-resolve';
            service 'mysql-server', 'restart';

            Rex::Logger::info( 'Creating database user: cpantesters' );
            my @access_hosts = uniq get( 'database_host' ), map { Rex::Group->get_group( $_ ) } qw( api backend web );
            my $pass = get 'database_password';
            for my $host ( @access_hosts ) {
                run qq{mysql -e'GRANT ALL ON *.* TO "cpantesters"@"$host" IDENTIFIED BY "$pass"'};
            }
        };
    };

=head2 export_dashboards

    rex -E vm export_dashboards

Export the Grafana dashboards so they can be saved in the Git repository.
Later, we can use C<import_dashboards> to import these dashboards.

=cut

desc 'Export the dashboards from this environment';
task export_dashboards =>
    sub {
        my $http = HTTP::Tiny->new;
        my $host = get 'monitor_host';
        my $port = get 'monitor_port';
        my $user = get 'monitor_user';
        my $pass = get 'monitor_password';
        for my $dashboard ( @grafana_dashboards ) {
            my $res = $http->get( sprintf 'http://%s:%s@%s:%d/api/dashboards/db/%s', $user, $pass, $host, $port, $dashboard );
            if ( !$res->{success} ) {
                Rex::Logger::info( sprintf( 'Failed to get dashboard %s: %s', $dashboard, $res->{content} ), 'error' );
                next;
            }
            file sprintf( 'etc/grafana/dashboards/%s.json', $dashboard ),
                content => $JSON->encode( $JSON->decode( $res->{content} ) );
        }
    };

=head2 import_dashboards

    rex import_dashboards

Import the Grafana dashboards so they can be used. We can edit them
and use C<export_dashboards> to export the dashboards for savekeeping.

=cut

desc 'Import the dashboards from this environment';
task import_dashboards =>
    sub {
        my $http = HTTP::Tiny->new;
        my $host = get 'monitor_host';
        my $port = get 'monitor_port';
        my $user = get 'monitor_user';
        my $pass = get 'monitor_password';
        for my $dashboard ( @grafana_dashboards ) {
            my $text = file_read( sprintf 'etc/grafana/dashboards/%s.json', $dashboard )->read_all;
            my $json = $JSON->decode( $text );
            my $slug = $json->{meta}{slug};

            # Check to see if it exists
            my $get_url = sprintf 'http://%s:%s@%s:%d/api/dashboards/db/%s', $user, $pass, $host, $port, $slug;
            my $get_res = $http->get( $get_url );
            if ( !$get_res->{success} ) {
                delete $json->{dashboard}{id};
            }
            else {
                my $res_json = decode_json( $get_res->{content} );
                $json->{dashboard}{id} = $res_json->{dashboard}{id};
            }

            my $post_url = sprintf 'http://%s:%s@%s:%d/api/dashboards/db', $user, $pass, $host, $port;
            my $post_res = $http->post( $post_url, { content => $JSON->encode( $json ), headers => { 'Content-Type' => 'application/json' } } );
            if ( !$post_res->{success} ) {
                Rex::Logger::info( sprintf( 'Failed to post dashboard %s: %s', $dashboard, $post_res->{content} ), 'error' );
                next;
            }
        }
    };

=head2 update_legacy_config

This updates the configuration for the legacy applications to ensure they
are using the correct database.

=cut

desc 'Update the config for the legacy applications to ensure they use the correct database';
task update_legacy_config =>
    group => [qw( legacy )],
    sub {
        my %legacy_config = (
            '/media/backend/cpantesters/page-requests' => {
                config => [qw(
                    data/settings.ini
                )],
            },
            '/media/backend/cpantesters/generate' => {
                config => [qw(
                    data/parse.ini data/regenerate.ini
                    data/settings.ini data/tail.ini
                )],
            },
            '/media/backend/cpantesters/reports-mailer' => {
                config => [qw(
                    data/preferences-daily.ini data/preferences.ini
                    data/preferences-weekly.ini
                )],
            },
            '/media/backend/cpantesters/cpanstats' => {
                config => [qw( data/addresses.ini data/settings.ini )],
            },
            '/media/backend/cpantesters/release' => {
                config => [qw( data/release.ini )],
            },
            '/media/backend/cpantesters/uploads' => {
                config => [qw( data/uploads.ini )],
            },
            '/media/web/www/cpanadmin' => {
                config => [qw( cgi-bin/config/settings.ini )],
            },
            '/media/web/www/cpanprefs' => {
                config => [qw( cgi-bin/config/settings.ini )],
            },
            '/media/web/www/reports' => {
                config => [qw( cgi-bin/config/settings.ini )],
            },
        );

        my $database = get 'database_host';
        my $dbuser = get 'database_user';
        my $dbpass = get 'database_password';

        ensure_sudo_password();
        sudo sub {
            for my $root ( keys %legacy_config ) {
                for my $file ( @{ $legacy_config{ $root }{ config } } ) {
                    my $path = join "/", $root, $file;
                    Rex::Logger::info( sprintf 'Checking %s database settings...', $path );
                    sed( qr{dbhost=\d+\.\d+\.\d+\.\d+}, "dbhost=$database", $path );
                    sed( qr{dbuser=\w+}, "dbuser=$dbuser", $path );
                    sed( qr{dbpass=.+}, "dbpass=$dbpass", $path );
                }
            }
        };
    };

=head2 service

    rex service [--command=<command>] [--services=<service>,...] [--force=1]

Restart services on the machine(s). C<--command> is the command to run
and defaults to C<restart> (use C<status> to get service status).
C<--services> is a comma-separated list of services to command (defaults
to C<*>, all services).  Use C<--force=1> to force-kill any service that
is not restarted/stopped.

=cut

task service =>
    group => [qw( all )],
    sub {
        my ( $opt ) = @_;
        my $command = $opt->{command} || 'restart';
        my @services = split( /,/, $opt->{services} );
        @services = ( '*' ) if !@services;
        my $services = join " ", map { '~cpantesters/service/' . $_ } @services;
        my $line = sprintf( 'sudo -u cpantesters sv %s %s', $command, $services );
        Rex::Logger::info( 'Running: ' . $line );
        my @out = run $line;
        Rex::Logger::info( $_ ) for @out;

        if ( $command =~ /restart|stop/ && $opt->{force} ) {
            for my $out ( grep { /^timeout:/ } @out ) {
                my ( $status, $state, $path, $pid ) = $out =~ /^([^:]+):\s+([^:]+):\s+([^:]+):\s+\(pid (\d+)\)/;
                my $service = basename $path;
                if ( $state eq 'run' && $pid ) {
                    Rex::Logger::info( 'Force killing ' . $pid );
                    run "kill $pid";
                }
                else {
                    Rex::Logger::info( sprintf 'Cannot force kill %s: Service is %s', $service, $state );
                }
            }
        }
    };

desc 'Start maintenance mode';
task 'start_maintenance' =>
    group => [qw( api web )],
    sub {
        ensure_sudo_password();
        sudo sub {
            Rex::Logger::info( 'Syncing maintenance site' );
            run 'mkdir -p /var/www/maintenance';
            sync_up 'var/www/maintenance', '/var/www/maintenance';
            Rex::Logger::info( 'Disabling app sites' );
            _disable_group_sites(qw( api www ));
            Rex::Logger::info( 'Enabling maintenance site' );
            _deploy_include_files();
            _deploy_group_sites( 'downtime' );
            Rex::Logger::info( 'Purging Fastly cache' );
            run 'curl -X PURGE https://cpantesters.org';
            run 'curl -X PURGE http://cpantesters.org';
            run 'curl -X PURGE https://www.cpantesters.org';
            run 'curl -X PURGE http://www.cpantesters.org';
        }
    };

desc 'Stop maintenance mode';
task 'stop_maintenance' =>
    group => [qw( api web )],
    sub {
        ensure_sudo_password();
        sudo sub {
            Rex::Logger::info( 'Enabling app sites' );
            _enable_group_sites(qw( api www ));
            Rex::Logger::info( 'Disabling maintenance site' );
            _disable_group_sites( 'downtime' );
            Rex::Logger::info( 'Purging Fastly cache' );
            run 'curl -X PURGE https://cpantesters.org';
            run 'curl -X PURGE http://cpantesters.org';
            run 'curl -X PURGE https://www.cpantesters.org';
            run 'curl -X PURGE http://www.cpantesters.org';
        }
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

=head2 _deploy_group_sites

Deploy the Apache configuration files for a given group. These are configured
in the C<%sites> hash, above.

=cut

sub _deploy_group_sites {
    my @groups = @_;
    for my $site ( map { @{ $sites{ $_ } } } @groups ) {
        Rex::Logger::info( "Installing Apache2 config for " . $site );
        file "/etc/apache2/sites-available/$site.conf",
            source => "etc/apache2/vhost/$site.conf";
    }
    _enable_group_sites( @groups );
}

sub _deploy_include_files {
    Rex::Logger::info( "Deploying Apache2 include files..." );
    file '/etc/apache2/include',
        ensure => 'directory',
        mode => 755,
        owner => 'root',
        group => 'root',
        ;
    sync_up 'etc/apache2/include', '/etc/apache2/include';
}

sub _enable_group_sites {
    my @groups = @_;
    for my $site ( map { @{ $sites{ $_ } } } @groups ) {
        Rex::Logger::info( 'Enabling Apache2 site ' . $site );
        run 'a2ensite ' . $site;
    }
    Rex::Logger::info( "Disabling Debian default site" );
    run 'a2dissite 000-default';
    Rex::Logger::info( "Restarting Apache..." );
    service apache2 => 'restart';
}

sub _disable_group_sites {
    my @groups = @_;
    for my $site ( map { @{ $sites{ $_ } } } @groups ) {
        Rex::Logger::info( 'Disabling Apache2 site ' . $site );
        run 'a2dissite ' . $site;
    }
    Rex::Logger::info( "Restarting Apache..." );
    service apache2 => 'restart';
}

