
use Rex -feature => [ 1.4 ];
use Rex::Commands::Rsync;
use Term::ReadKey;

group www => 'cpantesters3.dh.bytemark.co.uk';
group backend => 'cpantesters3.dh.bytemark.co.uk';
group db => 'cpantesters3.dh.bytemark.co.uk';

set backend_root_dir => '/media/backend/cpantesters';
set www_root_dir => '/var/www';
set db_root_dir => '/media/backend/mysql';

set common_packages => [ qw/
    build-essential git perl-doc perl vim logrotate ack-grep cpanminus
/ ];
set www_packages => [qw/ apache2 mysql-client /];
set backend_packages => [qw/ mysql-client libdbd-mysql-perl postfix rsync-daemon proftpd /];
set db_packages => [qw/ mysql-server mysql-client libdbd-mysql-perl /];

set backend_repo_map => {
    cpandevel => 'CPAN::Testers::WWW::Development',
    cpanstats => 'CPAN::Testers::WWW::Statistics',
    'cpanstats-excel' => 'CPAN::Testers::WWW::Statistics::Excel',
    generate => 'CPAN::Testers::Data::Generator',
    'generate-mailer' => 'CPAN::Testers::WWW::Generator::Mailer',
    release => 'CPAN::Testers::Data::Release',
    'reports-mailer' => 'CPAN::Testers::WWW::Reports::Mailer',
    uploads => 'CPAN::Testers::Data::Uploads',
    'uploads-mailer' => 'CPAN::Testers::Data::Uploads::Mailer',
};

# Deploy a Labyrinth site by deploying the vhost/ directory as the root, then
# deploying the lib/ directory inside the vhost/cgi-bin/ directory.

set www_repo_map => {
    cpanadmin => 'https://github.com/barbie/cpan-testers-www-admin.git',
    cpanprefs => 'https://github.com/barbie/cpan-testers-www-preferences.git',
    reports => 'https://github.com/barbie/cpan-testers-www-reports.git',
};

set www_labyrinth_version => {
    reports => 5.32,
    cpanadmin => 5.27,
    cpanprefs => 5.00,
};

set www_dirs => {
    cpan        => '/media/web/CPAN',
    backpan     => '/media/web/BACKPAN',
    pass        => '/media/web/www/reports/html/stats',
    stats       => '/media/web/www/cpanstats',
    devel       => '/media/web/www/cpandevel',
    prefs       => '/media/web/www/cpanprefs/html',
    admin       => '/media/web/www/cpanadmin/html',
    static      => '/media/web/www/reports/html/static',
    reports     => '/media/web/www/reports/html',
};

# The Vagrant VM for development purposes
environment vm => sub {
    group www => ''; # the Vagrant VM IP
    group backend => ''; # the Vagrant VM IP
    group db => ''; # the Vagrant VM IP
};

desc 'Prepare the machine for a CPANTesters role by installing OS packages';
task prepare =>
    sub {
        ensure_sudo_password();

        Rex::Logger::info( "Checking common packages" );
        sudo sub {
            install package => $_ for @{ get 'common_packages' };
        };
    };

desc 'Deploy the CPANTesters backend';
task deploy_backend =>
    group => [qw( backend )],
    sub {
        my $root = get 'backend_root_dir';

        ensure_sudo_password();

        Rex::Logger::info( "Checking backend packages" );
        sudo sub {
            install package => $_ for @{ get 'backend_packages' };
        };

        Rex::Logger::info( "Deploying logrotate.conf" );
        sudo sub {
            file $root . '/etc',
                ensure => 'directory';
            file $root . '/etc/logrotate.conf',
                source => './etc/logrotate.conf',
                owner => 'root',
                group => 'root',
                ;
        };

        Rex::Logger::info( "Deploying backend scripts" );
        sudo sub {
            sync 'backend/*', $root;
        };

        Rex::Logger::info( "Deploying crontabs" );
        sudo sub {
            file '/tmp/deploy', ensure => 'directory';
            file '/tmp/deploy/crontab-testers',
                source => './etc/crontab/backend',
                ;

            Rex::Logger::info( "Checking crontab diff" );
            run 'crontab -u barbie -l > /tmp/deploy/crontab-testers.previous';
            my $diff = scalar run 'diff -u /tmp/deploy/crontab-testers.previous /tmp/deploy/crontab-testers';
            if ( $? == 0 ) {
                Rex::Logger::info( "No changes in crontab" );
            }
            elsif ( $? != 1 ) {
                Rex::Logger::info( "Error running diff: $?" );
            }
            else {
                say $diff;
                Rex::Logger::info( "Updating crontab" );
                say scalar run 'crontab -u barbie /tmp/deploy/crontab-testers';
            }
        };
    };

desc 'Deploy the CPANTesters web app';
task deploy_www =>
    group => [qw( www )],
    sub {
        my $root = get 'www_root_dir';
        my %dist = %{ get 'www_repo_map' };

        ensure_sudo_password();

        Rex::Logger::info( "Checking www packages" );
        sudo sub {
            install package => $_ for @{ get 'www_packages' };
        };

        Rex::Logger::info( "Updating web app distributions" );
        for my $dist ( keys %dist ) {
            LOCAL {
                run 'mkdir -p dist';
                if ( -d "dist/$dist" ) {
                    run "cd dist/$dist && git pull";
                }
                else {
                    run "cd dist && git clone --depth 1 $dist{$dist} $dist";
                }
            }
        }

        Rex::Logger::info( "Deploying web app distributions" );
        my %labyrinth_version = %{ get 'www_labyrinth_version' };
        for my $dist ( keys %dist ) {
            Rex::Logger::info( "Staging: $dist" );
            run "mkdir -p /tmp/dist/$dist";
            sync "dist/$dist/vhost/.", "/tmp/dist/$dist/.";
            run "mkdir -p /tmp/dist/$dist/cgi-bin/lib";
            sync "dist/$dist/lib/.", "/tmp/dist/$dist/cgi-bin/lib/.";

            my $lversion = $labyrinth_version{ $dist };
            Rex::Logger::info( "Installing Labyrinth $lversion" );
            run "cpanm -l /tmp/dist/$dist/cgi-bin/lib Labyrinth\@$lversion";
            Rex::Logger::info( "Installing Labyrinth::Plugin::Core $lversion" );
            run "cpanm -l /tmp/dist/$dist/cgi-bin/lib Labyrinth::Plugin::Core\@5.19";

            Rex::Logger::info( "Diffing: $dist" );
            my $diff = scalar run "diff -ur $root/$dist /tmp/dist/$dist";
            if ( $? == 0 ) {
                Rex::Logger::info( "No changes in dist. Skipping." );
                next;
            }
            elsif ( $? != 1 ) {
                Rex::Logger::info( "Error running diff: $?. Skipping." );
                next;
            }

            say $diff;
            print "Install this dist? (Y/n): ";
            my $install = ReadLine(0);
            print "\n";

            if ( lc $install =~ /^y?\n$/ ) {
                Rex::Logger::info( "Installing: $dist" );
                #run "rsync -av /tmp/dist/$dist $root/$dist";
            }
            else {
                Rex::Logger::info( "Skipping $dist due to user input" );
            }
        }

        return;

        Rex::Logger::info( "Deploying httpd configs" );
        sudo sub {
            Rex::Logger::info( "Syncing apache configs" );
            sync 'etc/apache2', '/etc/apache2/sites-available';
            run 'a2ensite ' . $_ for qw( 100-perl.org 300-cpantesters 443-cpantesters );
            Rex::Logger::info( "Checking apache service" );
            service apache2 => ensure => 'started';
        };
    };

desc 'Deploy the CPANTesters database';
task deploy_db =>
    sub {
        ensure_sudo_password();

        Rex::Logger::info( "Checking DB packages" );
        sudo sub {
            install package => $_ for @{ get 'db_packages' };
        };

        Rex::Logger::info( "Checking mysqld service" );
        sudo sub {
            my %mysql_vars = (
                datadir => get( 'db_root_dir' ),
            );

            file '/etc/mysql/my.cnf',
                content => template( 'etc/mysql/my.cnf', %mysql_vars ),
                ;

            service mysqld => ensure => 'started';
        };
    };

sub ensure_sudo_password {
    return if sudo_password();
    print 'Password to use for sudo: ';
    ReadMode('noecho');
    sudo_password ReadLine(0);
    ReadMode('restore');
    print "\n";
}

