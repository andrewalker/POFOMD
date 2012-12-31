#!/usr/bin/perl

use strict;
use warnings;
use POFOMD::Schema;

use Text::Unaccent;

use Text::Unidecode;
use Text::CSV_XS;
use Text2URI;
use WWW::Sitemap::XML;

my $t = new Text2URI();

my $schema = POFOMD::Schema->connect( "dbi:Pg:host=localhost;dbname=pofomd",
    "postgres", "" );
my $rs         = $schema->resultset('Beneficiario');

my $loop = 0;
while (1) {
	$loop++;
	my $objs = $rs->search({}, { rows => 49999, page => $loop });
	last unless $objs->count;

	my $map = WWW::Sitemap::XML->new();
	while (my $item = $objs->next) {
		my $url = join('/', 'http://www.paraondefoiomeudinheiro.org.br', 'credor', $item->uri);

		$map->add(
			loc => $url,
			changefreq => 'daily',
			priority => 0.5 # default	
		);

		print "$url\n";
	}

	$map->write( "sitemaps-$loop.xml" );
}

#$map->write( 'sitemap.xml.gz' );

