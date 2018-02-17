#!	C:/Strawberry/perl/bin

# 	max_profit.pl 11-12/03/17, 17/02/18

use strict;
use warnings;

use List::MoreUtils qw(each_arrayref);
use Football::Favourites_Data_Model;
use Football::Team_Profit;
use Football::Team_Hash;
use Football::Spreadsheets::Max_Profit;
use Football::Globals qw( @csv_leagues @euro_csv_lgs);

my $euro = 0;
if (defined $ARGV [0]) {
	$euro = 1 if $ARGV[0] eq "-e"; 
}

my $in_path = (! $euro) ? 'C:/Mine/perl/Football/data/' : 'C:/Mine/perl/Football/data/Euro/';
my $out_file = (! $euro) ? 'C:/Mine/perl/Football/reports/max_profit.xlsx':
  'C:/Mine/perl/Football/reports/max_euro_profit.xlsx';
my $leagues = (! $euro) ? \@csv_leagues : \@euro_csv_lgs;
my $index = [ 0...$#$leagues ];
#my $index = [ 0...scalar (@$leagues) - 1 ];

main ();

sub main {
	my $model = Football::Favourites_Data_Model->new ();
	my $team_hash = Football::Team_Hash->new ();
	
	my $iterator = each_arrayref ($leagues, $index);
	while (my ($csv_league, $lg_idx) = $iterator->()) {
		my $file = $in_path.$csv_league.".csv";
		my $results = $model->update_current ($file, $csv_league);
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
	my @sorted = $team_hash->sort ();
	for my $team (@sorted) {
		print "\n$team : ". $team_hash->team($team)->stake." ".
							$team_hash->team($team)->home." ". $team_hash->team($team)->away." ".
							$team_hash->team($team)->total." = ".$team_hash->team($team)->percent ."%";
	}
	my $writer = Football::Spreadsheets::Max_Profit->new ( filename => $out_file, euro => $euro );
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

Steve Hope 2017, 2018

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut