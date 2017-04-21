use warnings;
use strict;
use Test::More;

BEGIN {
    use_ok( 'Process::Monitor', qw(grab_procs) );
}

ok( grab_procs( ['root'] ), 'grab_procs works' );
my $data_ref = grab_procs( ['root'] );
is( ref($data_ref), 'ARRAY' );

foreach my $row_ref ( @{$data_ref} ) {
    is( ref($row_ref), 'ARRAY' );
}

done_testing;

# vim: filetype=perl
