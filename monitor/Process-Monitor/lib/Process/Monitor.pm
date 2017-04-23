package Process::Monitor;
use strict;
use warnings;
use Proc::ProcessTable 0.53;
use List::Util 1.33 'any';
use Exporter 'import';

# VERSION

our @EXPORT_OK = qw(grab_procs);

=pod

=head1 NAME

Process::Monitor - search for specific user's process, collecting CPU and memory used, among other things

=head1 DESCRIPTION

This module provides a C<sub> to retrieve process information from specific users.

=head1 EXPORTS

The following functions are exported by demand:

=head2 grab_procs

Expects as parameters an array reference containing the list of corresponding logins of the users.

Returns an array reference, where each row is itself an array reference with the following 
content (in that specific order):

=over

=item *

The UNIX epoch time when this function was invoked. Useful to aggregate the data.

=item *

The associated user login.

=item *

pid

=item *

pctcpu

=item *

rss

=item *

state

=item *

start

=item *

cmndline

=back

per process that was created by the given users logins (UID, not effective UID).

Except for the first two indexes, all other items are described in the L<Proc::ProcessTable::Process> Pod.

=cut

sub grab_procs {

    my ($user_list_ref) = @_;
    my $procs = Proc::ProcessTable->new();
    my %users_map;

    foreach my $user ( @{$user_list_ref} ) {
        my $uid = getpwnam($user);
        $users_map{$uid} = $user;
    }

    my @data;
    my $now = time();

    foreach my $p ( @{$procs->table()} ) {

        if ( any { $p->uid == $_ } keys(%users_map) ) {
            my $pctcpu = ( $p->pctcpu ) + 0;
            push(
                @data,
                [
                    (
                        $now,      $users_map{ $p->uid },
                        $p->pid,   $pctcpu,
                        $p->rss,   $p->state,
                        $p->start, $p->cmndline
                    )

                ]
            );
        }

    }

    return \@data;

}

=pod

=head1 SEE ALSO

=over

=item *

L<Proc::ProcessTable>

=back

=head1 AUTHOR

Alceu Rodrigues de Freitas Junior, E<lt>arfreitas@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 of Alceu Rodrigues de Freitas Junior, E<lt>arfreitas@cpan.orgE<gt>

This file is part of Process Monitor project.

Process Monitor is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Process Monitor is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Linux Info.  If not, see <http://www.gnu.org/licenses/>.

=cut

1;
