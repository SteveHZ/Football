#!	C:/Strawberry/perl/bin

#	euro_results.pl 16-20/07/17
#	without Regexp::Grammars 28-30/07/17

#	Run euro_scrape.pl to retrieve results data from BBC website,
#	run this script to write to csv files then run update_euro.pl to create season.json.

use strict;
use warnings;

use Football::Globals qw( $month_names );
use Euro::Rename qw( $euro_teams );
use Data::Dumper;

my $date_parser = qr/
	\D+\s				# day
	(?<date>\d\d?)		# date
	\w\w\s				# date end (st,nd,rd,th)
	(?<month>\w+)		# month
/x;

my $game_parser = qr/
	(?<home>\D+)		# home team
	(?<home_score>\d)	# home score
	(?<away>\D+)		# away team
	(?<away_score>\d)	# away score
/x;

my $date;
my $year = 17;
my $in_path = "C:/Mine/perl/Football/data/Euro/scraped/";
my $out_path = "C:/Mine/perl/Football/data/Euro/cleaned/";

my %filenames = (
	"Irish" 	=> [ "Ireland Feb", "Ireland March", "Ireland April", "Ireland May" ],
	"Norwegian"	=> [ "Norway April", "Norway May" ],
	"Swedish"	=> [ "Sweden April", "Sweden May" ],
	"USA"		=> [ "USA March", "USA April", "USA May" ],
);

for my $league (keys %filenames) {
	my @games = ();

	for my $file (@{ $filenames{$league} } ) {
		my $filename = $in_path.$file.".txt";
		open my $fh, '<', $filename or die "Can't open $filename !!";
		chomp ( my $data = <$fh> );

		my $lines = prepare (\$data);
		for my $line (@$lines) {
			if ($line =~ $date_parser) {
				do_dates ( \%+ );
			} elsif ($line =~ $game_parser) {
				do_games ( \%+, \@games );
			}
		}
	}
	my $out_file = $out_path.$league.".csv";
	write_csv ($out_file, \@games);
}

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

sub write_csv {
	my ($csv_file, $games) = @_;

	print "\nWriting $csv_file...";
	open my $fh, '>', $csv_file or die "Unable to open $csv_file";

	print $fh "Date,Home Team,Away Team,Home,Away";
	for my $game (@$games) {
		print $fh "\n". $game->{date} .",".
						$game->{home_team} .",". $game->{away_team} .",".
						$game->{home_score}.",". $game->{away_score};
	}
	close $fh;
}
