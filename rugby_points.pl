#!	C:/Strawberry/perl/bin

# 	rugby_points.pl 23/05/16

use strict;
use warnings;
#use Data::Dumper;

use MyJSON qw(read_json write_json);
use Rugby::Spreadsheets::Rugby_Points;

my $json_path = 'C:/Mine/perl/Football/data/Rugby/';
my $json_in = $json_path.'season.json';
my $json_out = $json_path.'rugby_points.json';

main ();

sub main {
	my $range = [-70..70];

	my $hash = create_hash ($range);
	my $games = read_json ($json_in);
	do_hash ($hash, $games, $range);
}

sub create_hash {
	my $range = shift;
	my $hash = {};

	for my $points_diff (@$range) {
		$hash->{$points_diff} = 0;
	}
	return $hash;
}

sub do_hash {
	my ($hash, $games, $range) = @_;
	my $points_diff;

	for my $game ( @{$games->{'Super League'}} ) {
		$points_diff = $game->{home_score} - $game->{away_score};
		$hash->{$points_diff} ++;
	}

	for my $points (@$range) {
		if ($hash->{$points}) {
			printf ("\npoints difference - %3d games - %2d", $points, $hash->{$points});
		}
	}
	my $writer = Rugby::Spreadsheets::Rugby_Points->new ();
	$writer->do_rugby_points ($hash, $range);
}
