#	backdate_favs.pl 15/11/16 - 20/11/16
#	v1.1 18/06/17, 22/08/17

#	Run predict.pl -u at start of season to produce favourite sheets for current year
#	then run this script to produce history json file, check with predict.pl (no flags)

use strict;
use warnings;

use Football::Favourites_Model;
use Football::Favourites_Data_Model;
use Football::Globals qw( @league_names );
use MyJSON qw(write_json);

my $year = 2017;
my $num_weeks = 3;
my $in_path = 'C:/Mine/perl/Football/data/favourites';
my $out_path = 'C:/Mine/perl/Football/data';
my $json_file = "$out_path/favourites_history.json";

#	Number of games to read for each week
my $num_games = {
	'Premier League' 	=> [ 0,10,10],
	'Championship' 		=> [12,12,24],
	'League One'		=> [12,12,12],
	'League Two'		=> [12,12,12],
	'Conference'		=> [11,24,24],
	'Scots Premier' 	=> [ 6, 6, 6],
	'Scots Championship'=> [ 5, 5, 5],
	'Scots League One' 	=> [ 5, 5, 5],
	'Scots League Two' 	=> [ 5, 5, 5],
};

my $idxs = init ();
my $data = read_files ();
my $games = {};
my @results = ();

for my $week (0..$num_weeks - 1) {
	print "\nCalculating week no. ".($week + 1)." ...";
	my $fav_model = Football::Favourites_Model->new ( filename => 'uk' );
	for my $league (@league_names) {
		my $start = $idxs->{$league};
		my $end = $start + $num_games->{$league}[$week] - 1;

		push $games->{$league}->@*, $data->{$league}->@[$start..$end]);
#		push ( @{ $games->{$league} }, @{ $data->{$league} }[$start..$end]);
		$idxs->{$league} += $num_games->{$league}[$week];
		$fav_model->update ($league, $year, $games->{$league} );
	}

	push @results, $fav_model->hash;
}
print "\n\nWriting out JSON file ...\n";
write_json ($json_file, \@results);

sub init {
	my $start = {};
	for my $league (@league_names) {
		$start->{$league} = 0;
	}
	return $start;
}

sub read_files {
	my $data_model = Football::Favourites_Data_Model->new ();
	my $data = {};

	for my $league (@league_names) {
		my $file = "$in_path/$league/$year.csv";
		$data->{$league} = $data_model->update ($file);
	}
	return $data;
}

=pod

=head1 NAME

backdate_favs.pl

=head1 SYNOPSIS

perl backdate_favs.pl

=head1 DESCRIPTION

Backdate favourites data

=head1 AUTHOR

Steve Hope 2016

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
