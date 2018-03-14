#!	C:/Strawberry/perl/bin

# 	max_profit.pl 11-12/03/17
# 	euro_profit.pl 04/02/18, 11/02/18, 09/03/18

use strict;
use warnings;

use List::MoreUtils qw(each_arrayref);
use Football::Euro_Data_Model;
use Football::Team_Profit;
use Football::Team_Hash;
use Football::Spreadsheets::Max_Profit;

my $leagues = [ qw(Swedish Norwegian Irish American) ];
my $index = [ 0...$#$leagues ];

my $in_path = 'C:/Mine/perl/Football/data/Euro/';
my $out_file = 'C:/Mine/perl/Football/reports/euro/euro_profit.xlsx';

main ();

sub main {
	my $model = Football::Euro_Data_Model->new ();
	my $team_hash = Football::Team_Hash->new ();
	
	my $iterator = each_arrayref ($leagues, $index);
	while (my ($csv_league, $lg_idx) = $iterator->()) {
		my $file = $in_path.$csv_league.".csv";
		my $results = $model->read_csv ($file, $csv_league);
		$team_hash->add_teams ($results, $lg_idx);

		for my $game (@$results) {
		$team_hash->place_stakes ( $game->{home_team}, $game->{away_team} );
			if ($game->{result} eq 'H') {
				$team_hash->home_win ( $game->{home_team}, $game->{home_odds} );
			} elsif ($game->{result} eq 'A') {
				$team_hash->away_win ( $game->{away_team}, $game->{away_odds} );
			}
		}
	}

	my $sorted = $team_hash->sort ();
	for my $team (@{ $sorted->{totals} }) {
		print "\n$team : ". $team_hash->team($team)->stake." ".
							$team_hash->team($team)->home." ". $team_hash->team($team)->away." ".
							$team_hash->team($team)->total." = ".($team_hash->team($team)->percent * 100)."%";
	}
	my $writer = Football::Spreadsheets::Max_Profit->new ( filename => $out_file, euro => 1 );
	$writer->show ($team_hash, $sorted);
}

=pod

=head1 NAME

euro_profit.pl

=head1 SYNOPSIS

perl euro_profit.pl

=head1 DESCRIPTION

Calculate max profit spreadsheet

=head1 AUTHOR

Steve Hope 2017

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut