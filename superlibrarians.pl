#!/usr/bin/perl 

# Copyright 2015 Magnus Enger Libriotech

=head1 NAME

superlibrarians.pl - Add a superlibrarian to a bunch of sites.

=head1 SYNOPSIS

 sudo perl superlibrarians.pl --look_for oldadmin --newuser newadmin 
 
=cut

use String::MkPasswd qw(mkpasswd);
use Getopt::Long;
use Data::Dumper;
use Pod::Usage;
use Modern::Perl;
binmode STDOUT, ":utf8";

use lib '/usr/share/koha/lib';
use Koha::Patrons;
require C4::Context;

# Get options
my ( $look_for, $new_user, $verbose, $debug ) = get_options();

say "*** GENERAL ***" if $verbose;

# Generate random password
my $password = mkpasswd(
    -length     => 8,
    -minspecial => 0,
    -distribute => 1,
);
say $password;

# Get the list of Koha sites
my @sites = `sudo koha-list`;
foreach my $site ( @sites ) {

    chomp $site;
    my $config_file = "/etc/koha/sites/$site/koha-conf.xml";
    say "Trying to use $config_file" if $verbose;
    my $context = new C4::Context( $config_file );

    say "*** $site ***" if $verbose;

    # Look for the old admin user
    my $oldadmin = Koha::Patrons->find({ 'userid' => $look_for });
    my $categorycode = $oldadmin->categorycode;
    my $branchcode   = $oldadmin->branchcode;
    say "categorycode=$categorycode, branchcode=$branchcode" if $verbose;

    # Look for the new user
    my $newadmin = Koha::Patrons->find({ 'userid' => $new_user });
    if ( $newadmin ) {

        say "Found $new_user" if $verbose;

    } else {

        say "$new_user NOT FOUND, adding" if $verbose;

    }

}

=head1 OPTIONS

=over 4

=item B<-l, --lookfor>

Look for this username, and use things like categorycode and branchcode
from this user for the new user.

=item B<-n, --newuser>

If this user does not exist, add it. If it does exist, update the password.

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
    my $look_for = '';
    my $new_user = '';
    my $verbose  = '';
    my $debug    = '';
    my $help     = '';

    GetOptions (
        'l|lookfor=s' => \$look_for,
        'n|newuser=s' => \$new_user,
        'v|verbose'   => \$verbose,
        'd|debug'     => \$debug,
        'h|?|help'    => \$help
    );

    pod2usage( -exitval => 0 ) if $help;
    pod2usage( -msg => "\nMissing Argument: -l, --lookfor required\n", -exitval => 1 ) if !$look_for;
    pod2usage( -msg => "\nMissing Argument: -n, --newuser required\n", -exitval => 1 ) if !$new_user;

    return ( $look_for, $new_user, $verbose, $debug );

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
