#!	C:/Strawberry/perl/bin

# 	create_head2head.pl 09-24/02/16
#	renamed create_reports.pl 05/03/16
#	v2 10-13/04/16, 02/05/16
#	v2.1 27/05/17

use strict;
use warnings;

use lib 'C:/Mine/perl/Football';
use Football::Reports::Head2Head;
use Football::Reports::Favourites;
use Football::Reports::Reports;
use Football::Globals qw( @league_names @league_size $reports_season );
use MyJSON qw(read_json);

my $last_season = $reports_season;
my $english = [ 1995..$last_season ];
my $conference = [ 2005..$last_season ];
my $scottish = [ 2000..$last_season ];
my $fav_seasons = [ 2010..$last_season ];

my $h2h_start = $last_season - 5; # last six seasons

my $seasons = {
	'Premier League'	=> $english,
	'Championship'    	=> $english,
	'League One' 		=> $english,
	'League Two' 		=> $english,
	'Conference' 		=> $conference,
	'Scots Premier' 	=> $scottish,
	'Scots Championship'=> $scottish,
	'Scots League One' 	=> $scottish,
	'Scots League Two' 	=> $scottish,
	h2h_seasons			=> [ $h2h_start...$last_season ],
	all_seasons			=> [ 1995...$last_season ],
};

my $path = 'C:/Mine/perl/Football/data/';
my $teams_file = $path.'teams.json';

my $teams = read_json ($teams_file);
my $leagues = \@league_names;
my $league_size = \@league_size;
	
my $head2head = Football::Reports::Head2Head->new (
	leagues => $leagues,
	league_size => $league_size,
	all_teams => $teams,
	seasons => $seasons,
);

my $favs = Football::Reports::Favourites->new (
	leagues => $leagues,
	seasons => $fav_seasons,
);

my $reports = Football::Reports::Reports->new (
	leagues => $leagues,
	league_size => $league_size,
	seasons => $seasons,
);
$reports->run ($leagues, $seasons);


=pod

=head1 NAME

create_reports.pl

=head1 SYNOPSIS

perl create_reports.pl

=head1 DESCRIPTION

Create football reports

=head1 AUTHOR

Steve Hope 2016

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut