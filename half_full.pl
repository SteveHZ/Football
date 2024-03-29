# 	half_full.pl 07-21/05/16
#	use Football::Globals 18/06/17
# 	use Football_Data_Model read_csv 19/01/19

use strict;
use warnings;

use lib 'C:/Mine/perl/Football';
use Football::Football_Data_Model;
use Football::Scores_Iterator;
use Football::Spreadsheets::HalfTime_FullTime;
use Football::Globals qw( @league_names $last_season);
use MyJSON qw(write_json);

my $path = 'C:/Mine/perl/Football/data/historical/';
my $json_path = 'c:/Mine/perl/Football/data/';
my $json_file = $json_path.'half_full.json';
my $years = [ 2010..$last_season ];

my ($hash, $half_times) = create_hash ();
read_files ($hash, $half_times);
do_hash ($hash, $half_times);

sub create_hash {
	my $hash = {};
	my $half_times = {};

	my $it = Football::Scores_Iterator->new (
		hash => $hash,
		callback => sub {
			my ($hash, $half_time, $full_time) = @_;
			$hash->{$half_time}->{$full_time} = 0;
			$half_times->{$half_time} = 0;
		},
	);
	$it->run ();
	return ($hash, $half_times);
}

sub read_files {
	my ($hash, $half_times) = @_;
	my $data_model = Football::Football_Data_Model->new (
		my_keys => [ qw(date home_team away_team home_score away_score half_time_home half_time_away) ],
	);
	my ($half_time, $full_time);

	for my $league (@league_names) {
		for my $year (@$years) {
			my $games = $data_model->read_csv ($path.$league.'/'.$year.'.csv');

			for my $game (@$games) {
				$half_time = sprintf ("%d-%d", $game->{half_time_home}, $game->{half_time_away} );
				$full_time = sprintf ("%d-%d", $game->{home_score}, $game->{away_score} );
				$hash->{$half_time}->{$full_time} ++;
				$half_times->{$half_time} ++;
			}
		}
	}
}

sub do_hash {
	my ($hash, $half_times) = @_;

	my $results = get_results ($hash);
	write_json ($json_file, $results);
	my $sorted = sort_results ($results);

	my $writer = Football::Spreadsheets::HalfTime_FullTime->new ();
	$writer->do_half_times ($results, $sorted, $half_times);
}

sub get_results {
	my $hash = shift;
	my $results = {};

	my $it = Football::Scores_Iterator->new (
		hash => $hash,
		callback => sub {
			my ($hash, $half_time, $full_time) = @_;
			if ($hash->{$half_time}->{$full_time}) {
				$results->{$half_time}->{$full_time} = $hash->{$half_time}->{$full_time};
			}
		},
	);
	$it->run ();
	return $results;
}

sub sort_results {
	my $hash = shift;

	return [
		map  { $_->[0] }
		sort { $a->[1] <=> $b->[1] or
			   $a->[2] <=> $b->[2]
		}
		map  { [ $_, split ('-', $_) ] }
		keys (%$hash)
	];
}

=pod

=head1 NAME

half_full.pl

=head1 SYNOPSIS

perl half_full.pl

=head1 DESCRIPTION

Half and full time scores

=head1 AUTHOR

Steve Hope 2016

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
