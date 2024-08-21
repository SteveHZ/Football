#!	C:/Strawberry/perl/bin

#	create_rugby_teams.pl 23/07/16
#	2019 season done 04/12/18

#	This file is for team names to be used within predict.pl
#???To edit names from Football Data CSV files, use Euro::Rename
#	To edit names from BBC fixtures files use Football::Fixtures_Globals

use strict;
use warnings;

use MyJSON qw(write_json);
use MyLib qw(sort_HoA);

my $path = 'C:/Mine/perl/Football/data/Rugby/';
my $json_file = $path.'teams.json';

my $leagues = {
	'Super League' => [
		'Castleford',
		'Catalans',
		'Huddersfield',
		'Hull',
		'Hull KR',
		'Leeds',
		'Leigh',
		'London',
		'Salford',
		'St Helens',
		'Warrington',
		'Wigan',
	],
	'Championship' => [
		'Barrow',
		'Batley',
		'Bradford',
		'Dewsbury',
		'Doncaster',
		'Featherstone',
		'Halifax',
		'Sheffield',
		'Swinton',
		'Toulouse',
		'Wakefield',
		'Widnes',
		'Whitehaven',
		'York',
	],
	'League 1' => [
		'Cornwall',
		'Hunslet',
		'Keighley',
		'Midlands',
		'Newcastle',
		'Nth Wales',
		'Oldham',
		'Rochdale',
		'Workington',
	],
	'NRL' => [
		'Brisbane',
		'Canberra',
		'Canterbury',
		'Cronulla',
		'Gold Coast',
		'Manly',
		'Melbourne',
		'Newcastle',
		'Nth Queens',
		'NZ',
		'Parramatta',
		'Penrith',
		'St George',
		'Sth Sydney',
		'Sydney',
		'Wests',
	],
};

my $sorted = sort_HoA ($leagues);
write_json ($json_file, $sorted);
print "\nDone";

=pod

=head1 NAME

perl create_rugby_teams.pl

=head1 SYNOPSIS

perl create_rugby_teams.pl

=head1 DESCRIPTION

Create Rugby/teams.json file

=head1 AUTHOR

Steve Hope 2016

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
