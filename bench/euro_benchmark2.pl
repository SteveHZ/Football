#!	C:/Strawberry/perl/bin

#	euro_benchmark.pl 19/07/17

use strict;
use warnings;

use lib 'C:/Mine/perl/Football';
use Football::Globals qw( $month_names );
use Benchmark qw(:all);

use Football::Globals qw( $month_names );
use Euro::Rename qw( $euro_teams );

my $date_parser = qr/
	\w+\s				# day
	(?<date>\d\d?)		# date
	\w\w\s				# date end (st,nd,rd,th)
	(?<month>\w+)		# month
/x;

my $game_parser = qr/
	(?<home>\D+)		# home team
	(?<home_score>\d\d?)# home score
	(?<away>\D+)		# away team
	(?<away_score>\d\d?)# away score
/x;

my $in_path = 'C:/Mine/perl/Football/data/Euro/scraped/';
my @days = ("Friday ","Saturday ","Sunday ","Monday ","Tuesday ","Wednesday ","Thursday ");
my @months = qw(February March April May);
my @games = ();
my $date;
my $year = 17;

my $filename = $in_path.'USA April'.".txt";
open my $fh, '<', $filename or die "Can't open $filename !!";
chomp ( my $data = <$fh> );
my $lines = prepare (\$data);

my $t = timethese ( -60, {
	'with_line' => sub {
		for my $line (@$lines) {
			if ($line =~ $date_parser) {
				do_dates ( \%+ );
			} elsif ($line =~ $game_parser) {
				do_games ( \%+, \@games );
			}
		}
	},
	'without_line' => sub {
		for (@$lines) {
			if (/$date_parser/) {
				do_dates ( \%+ );
			} elsif (/$game_parser/) {
				do_games ( \%+, \@games );
			}
		}
	},
});
cmpthese $t;

sub prepare {
	my $dataref = shift;

#	Remove beginning and end of data
	$$dataref =~ s/^.*Content//;
	$$dataref =~ s/All times are UK.*$//g;

#	Turn unneeded tokens into new lines or blanks
	$$dataref =~ s/FT/\n/g;
	$$dataref =~ s/Eastern Conference//g;

#	Add new line after each month
	$$dataref =~ s/(February|March|April|May)/$1\n/g;

	my @lines = split /\n/,$$dataref;
	return \@lines;
}

sub do_dates {
	my $hash = shift;

	my $dt = sprintf "%02d", $hash->{date};
	my $month = $month_names->{ $hash->{month} };
	$date = "$dt/$month/$year";
}

sub do_games {
	my ($hash, $games) = @_;

#	Check for and rename teams with Unicode characters
	my $home = defined $euro_teams->{ $hash->{home} }
		? $euro_teams->{ $hash->{home} } : $hash->{home};
	my $away = defined $euro_teams->{ $hash->{away} }
		? $euro_teams->{ $hash->{away} } : $hash->{away};

	push @$games, {
		date => $date,
		home_team => $home,
		away_team => $away,
		home_score => $hash->{home_score},
		away_score => $hash->{away_score},
	};
}
