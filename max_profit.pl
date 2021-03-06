
# 	max_profit.pl 11-12/03/17, 17-18/02/18
#	v1.1 11/03/18, v1.2 02/04/18 v1.3 01/07/18 v1.4 09/12/18 v1.5 06/05/19
#   v2.0 17/09/19

#BEGIN { $ENV{PERL_KEYWORD_DEVELOPMENT} = 1; }

use MyHeader;
use MyKeyword qw(DEVELOPMENT);

use lib 'C:/Mine/perl/Football';

use Football::Max_Profit;
use Football::Spreadsheets::Max_Profit;
use MyJSON qw(write_json);

my $region = 0;
if (defined $ARGV [0]) {
	$region = 1 if $ARGV[0] eq "-e";
	$region = 2 if $ARGV[0] eq "-s";
}

my $maxp = Football::Max_Profit->new (region => $region);
my $sorted = $maxp->calc ();

my $filename = $maxp->get_filename ();
print "\nWriting $filename...";

my $writer = Football::Spreadsheets::Max_Profit->new ( filename => $filename, euro => $region );
$writer->show ($maxp->team_hash, $sorted);

my $datafile_name = $maxp->get_datafile_name ();
my $combine_file_data = $maxp->get_combine_file_data ($sorted);
write_json ($datafile_name, $combine_file_data);

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

#	DO NOT DELETE !!!
=head
# 	max_profit.pl 11-12/03/17, 17-18/02/18
#	v1.1 11/03/18, v1.2 02/04/18 v1.3 01/07/18 v1.4 09/12/18

#BEGIN { $ENV{PERL_KEYWORD_DEVELOPMENT} = 1; }

use strict;
use warnings;
use MyKeyword qw(DEVELOPMENT);
use List::MoreUtils qw(each_arrayref);

use lib 'C:/Mine/perl/Football';
use Football::Team_Hash;
use Football::Favourites::Data_Model;
use Summer::Summer_Data_Model;
use Football::Spreadsheets::Max_Profit;
use Football::Globals qw( @csv_leagues @euro_csv_lgs @summer_csv_leagues );

use Football::Model;
use Euro::Model;
use Summer::Model;
DEVELOPMENT { use Data::Dumper; }

my $euro = 0;
if (defined $ARGV [0]) {
	$euro = 1 if $ARGV[0] eq "-e";
	$euro = 2 if $ARGV[0] eq "-s";
}
my @funcs = (\&get_uk_data, \&get_euro_data, \&get_summer_data);
my $data = $funcs[$euro]->();
my $fixtures = $data->{model}->get_fixtures ();

my %markets = (
	"max_profit"	=> Football::Team_Hash->new (
		func 		=> sub { straight_win (@_) },
		fixtures	=> $fixtures
	),
#	"over_2pt5"		=> Football::Team_Hash->new ( func => \&over_2pt5 ),
#	"under_2pt5"	=> Football::Team_Hash->new ( func => \&under_2pt5 ),
);

my $iterator = each_arrayref ($data->{leagues}, $data->{index});
while (my ($csv_league, $lg_idx) = $iterator->()) {
	my $file = $data->{in_path}.$csv_league.".csv";
	my $results = $data->{read_func}->( undef, $file ); # no $self
	for my $market (keys %markets) {
		$markets{$market}->add_teams ($results, $lg_idx);
	}
	for my $game (@$results) {
#		DEVELOPMENT { print "\n$game->{home_team} v $game->{away_team}"; }
		for my $market (keys %markets) {
			$markets{$market}->func->( $markets{$market}, $game );
		}
	}
}

for my $market (keys %markets) {
	my $filename = "$data->{out_path}$market".'_'."$data->{model_type}.xlsx";
	my $team_hash = $markets{$market};
	my $sorted = $team_hash->sort ();

	print "\nWriting $filename...";
	my $writer = Football::Spreadsheets::Max_Profit->new ( filename => $filename, euro => $euro );
	$writer->show ($team_hash, $sorted);
}

sub straight_win {
	my ($team_hash, $game) = @_;
	$team_hash->place_stakes ( $game->{home_team}, $game->{away_team} );
	if ($game->{result} eq 'H') {
		$team_hash->home_win ( $game->{home_team}, $game->{home_odds} );
	} elsif ($game->{result} eq 'A') {
		$team_hash->away_win ( $game->{away_team}, $game->{away_odds} );
	}
}

sub over_2pt5 {
	my ($team_hash, $game) = @_;
	$team_hash->place_stakes ($game->{home_team}, $game->{away_team} );
	if ($game->{home_score} + $game->{away_score} > 2) {
		$team_hash->home_win ( $game->{home_team}, $game->{over_odds} );
		$team_hash->away_win ( $game->{away_team}, $game->{over_odds} );
	}
}

sub under_2pt5 {
	my ($team_hash, $game) = @_;
	$team_hash->place_stakes ($game->{home_team}, $game->{away_team} );
	if ($game->{home_score} + $game->{away_score} < 3) {
		$team_hash->home_win ( $game->{home_team}, $game->{under_odds} );
		$team_hash->away_win ( $game->{away_team}, $game->{under_odds} );
	}
}

=cut
