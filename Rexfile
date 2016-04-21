
use Rex -feature => [ 1.4 ];
use Term::ReadKey;

group www => 'www.cpantesters.org';
group backend => 'www.cpantesters.org';
group database => 'www.cpantesters.org';

set backend_root_dir => '/media/backend/cpantesters';
set www_root_dir => '/var/www';
set database_root_dir => '/media/backend/mysql';

desc 'Deploy the CPANTesters backend';
task deploy_backend =>
    group => [qw( backend )],
    sub {
        my $root = get 'backend_root_dir';

        ensure_sudo_password();

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
    };

sub ensure_sudo_password {
    return if sudo_password();
    print 'Password to use for sudo: ';
    ReadMode('noecho');
    sudo_password ReadLine(0);
    ReadMode('restore');
}

