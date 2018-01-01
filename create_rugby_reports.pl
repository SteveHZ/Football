#!	C:/Strawberry/perl/bin

#	create_rugby_reports 07/05/17

use strict;
use warnings;

use lib 'C:/Mine/perl/Football';
use Rugby::Reports::Head2Head;
use Rugby::Reports::Reports;
use Rugby::Globals qw( @league_names @league_size $season $reports_start );
use MyJSON qw(read_json);

my $all_seasons = [ $reports_start..$season ];
my $seasons = {
	'Super League'		=> $all_seasons,
	'Championship'    	=> $all_seasons,
	'League One' 		=> $all_seasons,
	'NRL' 				=> $all_seasons,
	'Middle 8s' 		=> $all_seasons,
	'h2h_seasons'		=> $all_seasons,
	'all_seasons'		=> $all_seasons,
};

my $path = 'C:/Mine/perl/Football/data/Rugby/';
my $teams_file = $path.'teams.json';

my $teams = read_json ($teams_file);
my $leagues = \@league_names;
my $league_size = \@league_size;
	
my $head2head = Rugby::Reports::Head2Head->new (
	leagues => $leagues,
	league_size => $league_size,
	all_teams => $teams,
	seasons => $seasons,
);
my $reports = Rugby::Reports::Reports->new (
	leagues => $leagues,
	league_size => $league_size,
	seasons => $seasons,
);
$reports->run ($leagues, $seasons);


=pod

=head1 NAME

create_rugby_reports.pl

=head1 SYNOPSIS

perl create_rugby_reports.pl

=head1 DESCRIPTION

Create rugby reports

=head1 AUTHOR

Steve Hope 2017

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut