#!/usr/bin/perl

# List all Koha instances on a server, and some of their properties.

use File::Slurper 'read_lines';
use Text::Table::Tiny;
use Data::Dumper;
use Modern::Perl;

my @all_sites     = `sudo koha-list`;
my @enabled_sites = `sudo koha-list --enabled`;
my @email_sites   = `sudo koha-list --email`;
my @sip2_sites    = `sudo koha-list --sip`;
my @plack_sites   = `sudo koha-list --plack`;

my $sites_data;
foreach my $site ( @all_sites ) {

    chomp $site;
    $sites_data->{ $site }->{ 'enabled' } = 'No';
    $sites_data->{ $site }->{ 'email' }   = '';
    $sites_data->{ $site }->{ 'sip2' }    = '';
    $sites_data->{ $site }->{ 'plack' }   = '';

}

foreach my $site ( @enabled_sites ) { 

    chomp $site;
    $sites_data->{ $site }->{ 'enabled' } = '';

}

foreach my $site ( @email_sites ) { 

    chomp $site;
    $sites_data->{ $site }->{ 'email' } = 'Yes';

}

foreach my $site ( @sip2_sites ) { 

    chomp $site;
    $sites_data->{ $site }->{ 'sip2' } = 'Yes';

}

foreach my $site ( @plack_sites ) {

        chomp $site;
            $sites_data->{ $site }->{ 'plack' } = 'Yes';

        }

# Table headers
my $sites = [ [ 'Name', 'Enabled', 'Email', 'SIP2', 'HTTPS', 'Plack', 'Records', 'Items', 'Borrowers', 'Loans' ] ];

my $biblio_total = 0;
my $items_total = 0;
my $borrowers_total = 0;
my $issues_total = 0;

foreach my $site_name ( @all_sites ) {

    chomp $site_name;

    my $biblio_count    = sql_count( $site_name, 'biblio' );
    my $items_count     = sql_count( $site_name, 'items' );
    my $borrowers_count = sql_count( $site_name, 'borrowers' );
    my $issues_count    = sql_count( $site_name, 'issues' );

    push @{ $sites }, [
        $site_name, 
        $sites_data->{ $site_name }->{'enabled'},
        $sites_data->{ $site_name }->{'email'},
        $sites_data->{ $site_name }->{'sip2'},
        check_apache( $site_name, 'SSLCertificateFile' ),
        $sites_data->{ $site_name }->{'plack'},
        $biblio_count,
        $items_count,
        $borrowers_count,
        $issues_count,
    ];

    $biblio_total    += $biblio_count;
    $items_total     += $items_count;
    $borrowers_total += $borrowers_count;
    $issues_total    += $issues_count;

}

say Text::Table::Tiny::table(rows => $sites, header_row => 1);

say "Total sites:   " . scalar @all_sites;
say "Enabled sites: " . scalar @enabled_sites;
say "Records:       $biblio_total";
say "Items:         $items_total";
say "Borrowers:     $borrowers_total";
say "Loans:         $issues_total";

sub check_apache {

    my ( $site, $var ) = @_;
    my $config = "/etc/apache2/sites-enabled/$site.conf";
    my @lines = read_lines( $config );
    foreach my $line ( @lines ) {
        if ( $line =~ m/$var/i && $line !~ /#/ ) {
            return "Yes";
        }
    }

}

sub sql_count {

    my ( $site, $table ) = @_;
    my $count = `echo "SELECT COUNT(*) AS count FROM $table" | sudo koha-mysql $site | sed -n '2 p'`;
    chomp $count;
    return $count;

}
