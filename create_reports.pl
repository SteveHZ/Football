
# 	create_head2head.pl 09-24/02/16
#	renamed create_reports.pl 05/03/16
#	v2 10-13/04/16, 02/05/16
#	v2.1 27/05/17

#	Before running create_reports.pl
#	Change Football::Globals::$season to NEXT year (ie At the end of 2021-2022 season, change $season to 2022)
#	perl archive_csv.pl
#	perl amend_historical.pl
#	perl create_reports.pl


use strict;
use warnings;

use lib 'C:/Mine/perl/Football';
use Football::Reports::Head2Head;
use Football::Reports::Favourites;
use Football::Reports::Reports;
use Football::Globals qw( @league_names @league_size $reports_season $reports_seasons );
use MyJSON qw(read_json);

my $path = 'C:/Mine/perl/Football/data';
my $teams_file = "$path/teams.json";

my $teams = read_json ($teams_file);
my $leagues = \@league_names;
my $league_size = \@league_size;

my $fav_seasons = [ 2010..$reports_season ];

my $head2head = Football::Reports::Head2Head->new (
	leagues => $leagues,
	league_size => $league_size,
	all_teams => $teams,
	seasons => $reports_seasons,
);

my $favs = Football::Reports::Favourites->new (
	leagues => $leagues,
	seasons => $fav_seasons,
);

my $reports = Football::Reports::Reports->new (
	leagues => $leagues,
	league_size => $league_size,
	seasons => $reports_seasons,
);
$reports->run ($leagues, $reports_seasons);

=pod

=head1 NAME

create_reports.pl

=head1 SYNOPSIS

perl create_reports.pl

 Before running create_reports.pl,
 Change Football::Globals::$season to NEXT year (ie At the end of 2021-2022 season, change $season to 2022)
 perl archive_csv.pl
 perl amend_hostorical.pl
 perl create_reports.pl

=head1 DESCRIPTION

Create football reports

=head1 AUTHOR

Steve Hope 2016

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
