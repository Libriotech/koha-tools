#!/usr/bin/perl 

# Copyright 2017 Magnus Enger Libriotech

=head1 NAME

itemtype_item2bib.pl - Update 942$c from 952$y

=head1 SYNOPSIS

 # sudo koha-shell <instance>
 $ perl itemtype_item2bib.pl -v
 
=cut

use Getopt::Long;
use Data::Dumper;
use Pod::Usage;
use Modern::Perl;
binmode STDOUT, ":utf8";

use C4::Biblio;
use C4::Context;
use C4::Items;

# Get options
my ( $limit, $verbose, $debug ) = get_options();

my $dbh = C4::Context->dbh;

my $querysth =  qq{ SELECT biblionumber from biblio_metadata };
$querysth    .= " LIMIT $limit" if ( $limit );
my $query = $dbh->prepare( $querysth );
$query->execute;

my $count = 0;
my $count_modified = 0;
while ( my $biblionumber = $query->fetchrow ){

    $count++;
    my $record = GetMarcBiblio({ biblionumber => $biblionumber });
    say Dumper $record if $debug;

    # Find the first item
    my $item_itype = '';
    my @items = GetItemsInfo( $biblionumber );
    my $item = $items[0];
    if ( $item ) {
        $item_itype = $item->{'itype'};
    }

    # Find 952c
    my $record_itype = '';
    if ( $record->subfield( '942', 'c' )) {
        $record_itype = $record->subfield( '942', 'c' );
    }

    say "Record level: $record_itype -> Item level: $item_itype";

    # Modify the record
    my $field942 = $record->field( '942' );
    if ( $item && $field942 && $record->subfield( '942', 'c' ) && $item_itype ne '' ) {
        $field942->update( 'c' => $item_itype );
    } 
    unless ( $field942 ) {
        say "Missing 942 for biblionumber = $biblionumber";
        if ( $item_itype ne '' ) {
            my $new_field942 = MARC::Field->new(
                942, '', '',
                'c' => $item_itype,
            );
            $record->insert_fields_ordered( $new_field942 );
        }
    }

    if ($record) {
        ModBiblio($record, $biblionumber, GetFrameworkCode($biblionumber));
        $count_modified++;
    } else {
        say "error in $biblionumber : can't parse biblio";
    }
}

say "$count records processed, $count_modified modified" if $verbose;

=head1 OPTIONS

=over 4

=item B<-l, --limit>

Only process the n first records.

=item B<-v --verbose>

More verbose output.

=item B<-d --debug>

Even more verbose output.

=item B<-h, -?, --help>

Prints this help message and exits.

=back

=cut

sub get_options {

    # Options
    my $limit   = '';
    my $verbose = '';
    my $debug   = '';
    my $help    = '';

    GetOptions (
        'l|limit=i'  => \$limit,
        'v|verbose'  => \$verbose,
        'd|debug'    => \$debug,
        'h|?|help'   => \$help
    );

    pod2usage( -exitval => 0 ) if $help;

    return ( $limit, $verbose, $debug );

}

=head1 AUTHOR

Magnus Enger, <magnus [at] libriotech.no>

=head1 LICENSE

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.

=cut
