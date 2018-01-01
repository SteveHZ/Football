#! 	C:/Strawberry/perl/bin

#	make_results.pl 25-31/07/17

use strict;
use warnings;
use Data::Dumper;

use lib 'C:/Mine/perl/Fixtures/lib';
use Rugby_Model;
use Euro_Model;
use Rugby_Results;

use Football::Globals qw ( @summer_leagues );
use Rugby::Globals qw ( @fixtures_leagues );

die "Usage : perl make_results.pl [-e -r]"
	unless @ARGV == 1 and $ARGV[0] =~ /^-[e|r]$/i;

my ($fixtures_model, $leagues);
my $path = "C:/Mine/perl/Football/data/";

if (lc $ARGV[0] eq "-e") {
	$fixtures_model = Euro_Model->new ();
	$leagues = \@summer_leagues;
	$path .= "Euro/";
} else {
	$fixtures_model = Rugby_Model->new ();
	$leagues = \@fixtures_leagues;
	$path .= "Rugby/";
}

my $fixtures_file = $path."fixtures.csv";
my $results_file = $path."results.xlsx";

my $fixtures = $fixtures_model->read_fixtures ($fixtures_file);
my $results_model = Rugby_Results->new (filename => $results_file);
$results_model->write ($leagues, $fixtures);

print Dumper $fixtures;
print "Done writing $results_file...\n";

=pod

=head1 NAME

make_results.pl

=head1 SYNOPSIS

perl make_results.pl -e
perl make_results.pl -r

=head1 DESCRIPTION

Create new results.xlsx file from existing fixtures.csv file
for either Euro (-e) or Rugby (-r) folders

=head1 AUTHOR

Steve Hope 2017

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut