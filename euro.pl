#!	C:/Strawberry/perl/bin
#	euro.pl 27-29/12/16, 27/01/18

#	Need to clear previous year data before a new season

use strict;
use warnings;

use Spreadsheet::Read qw(rows);

use lib 'C:/Mine/perl/Football';
use Football::Favourites_Model;
use Football::Spreadsheets::Favourites;
use Football::Globals qw( @euro_leagues $season );
use Football::Utils qw(get_odds_cols);

my $year = $season;
my $path = "C:/Mine/perl/Football/data/";
my $filename = $path."all-euro-data-2017-2018.xlsx";

main ();

sub main {
	my $hash = update ();
	my $view = Football::Spreadsheets::Favourites->new (filename => 'euro');
	$view->do_favourites ($hash);
}

sub update {
	my $fav_model = Football::Favourites_Model->new (update => 1, filename => 'euro');

	print "\nReading data...";
	my $book = Spreadsheet::Read->new ($filename);
	my @sheetnames = $book->sheets;

	print "\nCalculating...";
	for my $sheet (1..scalar @sheetnames) {
		my $league = $euro_leagues[$sheet - 1];
		my $csv_sheetname = $sheetnames[$sheet - 1];
		
		my @rows = rows ($book->[$sheet]);
		my $results = get_data (\@rows);
		$fav_model->update ($league, $year, $results);
	}
	view ($fav_model, \@euro_leagues, $year);

	return {
		data => $fav_model->hash (),
		history => $fav_model->history (),
		leagues => \@euro_leagues,
		year => $year,
	};
}

sub get_data {
	my $rows = shift;

	my @odds_cols = get_odds_cols ($rows);
	my @league_games = ();

	for my $match (@$rows[1..scalar(@$rows)-1]) {
		next if @$match[$odds_cols[0]] eq ""; # Some Greek games have no odds

		push ( @league_games, {
			league => @$match [0],
			date => @$match [1],
			home_team => @$match [2],
			away_team => @$match [3],
			home_score => @$match [4],
			away_score => @$match [5],
			result => @$match [6],
			home_odds => @$match[ $odds_cols[0] ],
			draw_odds => @$match[ $odds_cols[1] ],
			away_odds => @$match[ $odds_cols[2] ],
		});
	}
	return \@league_games;
}

sub view {
	my ($fav_model, $leagues, $year) = @_;
	
	for my $league (@$leagues) {
		my $hashref = $fav_model->hash->{$league}->{$year};

		print "\n".$league;
		print "\t Stake = ".$hashref->{stake};
		print "\t Fav = ".$hashref->{fav_winnings};
		print "\t Under = ".$hashref->{under_winnings};
		print "\t Draw = ".$hashref->{draw_winnings};
		print "\t Underdogs" if $hashref->{under_winnings} > $hashref->{stake};
		print "\t Draws" if $hashref->{draw_winnings} > $hashref->{stake};
	}
}

=pod

=head1 NAME

euro.pl

=head1 SYNOPSIS

perl euro.pl

=head1 DESCRIPTION

Create favourites spreadsheet for all European leagues

=head1 AUTHOR

Steve Hope 2016

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut