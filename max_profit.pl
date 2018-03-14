#!	C:/Strawberry/perl/bin

# 	max_profit.pl 11-12/03/17, 17-18/02/18
#	v1.1 11/03/18

use strict;
use warnings;

use List::MoreUtils qw(each_arrayref);
use Football::Favourites_Data_Model;
use Summer::Summer_Data_Model;
use Football::Team_Profit;
use Football::Team_Hash;
use Football::Spreadsheets::Max_Profit;
use Football::Globals qw( @csv_leagues @euro_csv_lgs @summer_leagues );

my $euro = 0;
if (defined $ARGV [0]) {
	$euro = 1 if $ARGV[0] eq "-e";
	$euro = 2 if $ARGV[0] eq "-s";
}
my @funcs = (\&get_uk_data, \&get_euro_data, \&get_summer_data);
my $data = $funcs[$euro]->();

main ();

sub main {
	my $team_hash = Football::Team_Hash->new ();
	
	my $iterator = each_arrayref ($data->{leagues}, $data->{index});
	while (my ($csv_league, $lg_idx) = $iterator->()) {
		my $file = $data->{in_path}.$csv_league.".csv";
		my $results = $data->{read_func}->(undef, $file, $csv_league); # no $self
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
	my $writer = Football::Spreadsheets::Max_Profit->new ( filename => $data->{out_file}, euro => $euro );
	$writer->show ($team_hash, $sorted);
}

sub get_uk_data {
	return {
		read_func 	=> \&Football::Favourites_Data_Model::update_current,
		in_path 	=> 'C:/Mine/perl/Football/data/',
		out_file 	=> 'C:/Mine/perl/Football/reports/max_profit.xlsx',
		leagues 	=> \@csv_leagues,
		index 		=> [ 0...$#csv_leagues ],
	}
}

sub get_euro_data {
	return {
		read_func 	=> \&Football::Favourites_Data_Model::update_current,
		in_path 	=> 'C:/Mine/perl/Football/data/Euro/',
		out_file 	=> 'C:/Mine/perl/Football/reports/Euro/max_euro_profit.xlsx',
		leagues 	=> \@euro_csv_lgs,
		index 		=> [ 0...$#euro_csv_lgs ],
	}
}

sub get_summer_data {
	return {
		read_func 	=> \&Summer::Summer_Data_Model::read_csv,
		in_path 	=> 'C:/Mine/perl/Football/data/Summer/',
		out_file 	=> 'C:/Mine/perl/Football/reports/Summer/max_summer_profit.xlsx',
		leagues 	=> \@summer_leagues,
		index 		=> [ 0...$#summer_leagues ],
	}
}

=pod

=head1 NAME

max_profit.pl

=head1 SYNOPSIS

 perl max_profit.pl
 Run as max_profit.pl for UK leagues
 Run as max_profit.pl -e for European winter leagues
 Run as max_profit.pl -s for European and US summer leagues

=head1 DESCRIPTION

Calculate max profit spreadsheet

=head1 AUTHOR

Steve Hope 2017, 2018

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut