
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

XXX: The C<prepare_backend> task is not completed

The backend daemons and jobs are deployed by L<the
CPAN::Testers::Backend
Rexfile|http://github.com/cpan-testers/cpantesters-backend>.

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
group api => qw( cpantesters3.dh.bytemark.co.uk cpantesters1.barnyard.co.uk );
group backend => 'cpantesters3.dh.bytemark.co.uk';
group web => 'cpantesters3.dh.bytemark.co.uk';
group monitor => 'monitor.preaction.me';

# The prod database is _not_ accessible via SSH from the outside world
group database => '216.246.80.45';

#######################################################################
# Settings

set perl_version => '5.24.0';
set perlbrew_root => '/opt/local/perlbrew';

set common_packages => [ qw/
    build-essential git perl-doc perl vim logrotate ack-grep ntp
/ ];

my @web_packages = qw/ apache2 runit perlbrew libmysqlclient-dev /;
set api_packages => \@web_packages;

set database_host => '216.246.80.45';
set database_name => 'cpanstats';
set database_user => 'cpantesters';
set database_password => 'Md5syMxdsKcf6n6eK';

set monitor_host => 'monitor.preaction.me';
set monitor_port => '3000';
set monitor_user => 'admin';
set monitor_password => 'YKn-sfS-a3U-KFs';
set monitor_mysql_user => 'monitor';
set monitor_mysql_password => 'fQZsTa6nvS83zjX';
set monitor_mysql_hosts => [qw( 216.246.80.45 216.246.80.46 )];

my %sites = (
    api => [qw( api.cpantesters.org metabase.cpantesters.org )],
    www => [qw( beta.cpantesters.org )], # www.cpantesters.org
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

        Rex::Logger::info( "Checking common packages" );
        sudo sub {
            install package => $_ for @{ get 'common_packages' };
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
        };

        _deploy_group_sites( "api" );
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
            sync_up 'etc/systemd', '/etc/systemd/system', {
                files => {
                    mode => 664,
                },
            };
            run 'systemctl enable runsvdir';
            run 'systemctl start runsvdir';

            Rex::Logger::info( 'Preparing crontab environment' );
            cron env => 'cpantesters' => add => {
                PERL5LIB => '/home/cpantesters/perl5/lib/perl5',
                PATH => '/home/cpantesters/perl5/bin:/opt/local/perlbrew/bin:/opt/local/perlbrew/perls/perl-5.24.0/bin:/usr/local/bin:/usr/bin:/bin',
                MAILTO => 'doug@preaction.me',
            };
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
                    ( map { $_ => get "monitor_$_" } qw( host user name password ) ),
                ),
                on_change => sub { service 'grafana-server' => 'stop' },
                ;

            Rex::Logger::info( 'Starting services' );
            service 'postfix', ensure => 'started';
            service 'grafana-server', ensure => 'started';
            service 'td-agent', ensure => 'started';
            service 'influxdb', ensure => 'started';
            service 'telegraf', ensure => 'started';
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
    my ( $group ) = @_;
    for my $site ( @{ $sites{ $group } } ) {
        Rex::Logger::info( "Installing reverse proxy for " . $site );
        file "/etc/apache2/sites-available/$site.conf",
            source => "etc/apache2/vhost/$site.conf";
        run 'a2ensite ' . $site;
    }
    Rex::Logger::info( "Disabling Debian default site" );
    run 'a2dissite 000-default';
    Rex::Logger::info( "Restarting Apache..." );
    service apache2 => 'restart';
}

