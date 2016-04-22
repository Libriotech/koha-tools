#!/usr/bin/perl

# List all Koha instances on a server, and some of their properties.

use File::Slurper 'read_lines';
use Text::Table::Tiny;
use Data::Dumper;
use Modern::Perl;

my @all_sites = `sudo koha-list`;
my @enabled_sites = `sudo koha-list --enabled`;
my @email_sites = `sudo koha-list --email`;
my @sip2_sites = `sudo koha-list --sip`;

my $sites_data;
foreach my $site ( @all_sites ) {

    chomp $site;
    $sites_data->{ $site }->{ 'enabled' } = 'No';
    $sites_data->{ $site }->{ 'email' }   = '';
    $sites_data->{ $site }->{ 'sip2' }   = '';

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

# Table headers
my $sites = [ [ 'Name', 'Enabled', 'Email', 'SIP2', 'HTTPS', 'Records', 'Items', 'Borrowers', 'Loans' ] ];

foreach my $site_name ( @all_sites ) {

    chomp $site_name;
    push $sites, [
        $site_name, 
        $sites_data->{ $site_name }->{'enabled'},
        $sites_data->{ $site_name }->{'email'},
        $sites_data->{ $site_name }->{'sip2'},
        check_apache( $site_name, 'SSLCertificateFile' ),
        sql_count( $site_name, 'biblio' ),
        sql_count( $site_name, 'items' ),
        sql_count( $site_name, 'borrowers' ),
        sql_count( $site_name, 'issues' )
    ];

}

say Text::Table::Tiny::table(rows => $sites, header_row => 1);

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
