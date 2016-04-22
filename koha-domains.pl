#!/usr/bin/perl

# List Koha instances and some of their properties.

use File::Slurper 'read_lines';
use Modern::Perl;

my @sites = `sudo koha-list --enabled`;

foreach my $site ( @sites ) {

    chomp $site;
    say "*** $site ***";

    # Apache config
    my @lines = read_lines( "/etc/apache2/sites-enabled/$site.conf" );
    foreach my $line ( @lines ) {

        chomp $line;    
        if ( $line =~ m/ServerName|ServerAlias/gi ) {
            say $line;
        }

    }

    print "\n";

}
