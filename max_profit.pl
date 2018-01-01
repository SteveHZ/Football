#!	C:/Strawberry/perl/bin

# 	max_profit.pl 11-12/03/17

use strict;
use warnings;

use Football::Favourites_Data_Model;
use Football::Team_Profit;
use Football::Team_Hash;
use Football::Spreadsheets::Max_Profit;
use Football::Globals qw( @csv_leagues );

my $in_path = 'C:/Mine/perl/Football/data/';
my $out_file = 'C:/Mine/perl/Football/reports/max_profit.xlsx';

main ();

sub main {
	my $model = Football::Favourites_Data_Model->new ();
	my $team_hash = Football::Team_Hash->new ();
	
	for my $csv_league (@csv_leagues) {
		my $file = $in_path.$csv_league.".csv";
		my $results = $model->update_current ($file, $csv_league);
		$team_hash->add_teams ($results);

		for my $game (@$results) {
			$team_hash->place_stakes ( $game->{home_team}, $game->{away_team} );
			if ($game->{result} eq 'H') {
				$team_hash->home_win ( $game->{home_team}, $game->{home_odds} );
			} elsif ($game->{result} eq 'A') {
				$team_hash->away_win ( $game->{away_team}, $game->{away_odds} );
			}
		}
	}
	my @sorted = $team_hash->sort ();
	for my $team (@sorted) {
		print "\n$team : ". $team_hash->team($team)->stake." ".
							$team_hash->team($team)->home." ". $team_hash->team($team)->away." ".
							$team_hash->team($team)->total." = ".$team_hash->team($team)->percent ."%";
	}
	my $writer = Football::Spreadsheets::Max_Profit->new ( filename => $out_file );
	$writer->show ($team_hash, \@sorted);
}

=pod

=head1 NAME

max_profit.pl

=head1 SYNOPSIS

perl max_profit.pl

=head1 DESCRIPTION

Calculate max profit spreadsheet

=head1 AUTHOR

Steve Hope 2017

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut