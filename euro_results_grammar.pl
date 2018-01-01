#!	C:/Strawberry/perl/bin

#	euro_results.pl 16-20/07/17
#	renamed euro_results_grammar 29/07/17

#	Run euro_scrape.pl to retrieve results data from BBC website,
#	run this script to write to csv files then run update_euro.pl to create season.json.

use strict;
use warnings;

use Regexp::Grammars;
use Football::Globals qw( $month_names );
use Euro::Rename qw( $euro_teams );

my $date_parser = qr/
	<Date>
	<rule: Date>		<.date_hack><.day><.ws>
						<date=date><.date_end><.ws>
						<month=month>
	<token: day>		\D+
	<token: date>		\d\d?
	<token: month>		\w+
	<token: date_end>	\w\w
	<token: date_hack>	\#
/;

my $game_parser = qr/
	<Results>
	<rule: Results>		<home=Word><home_score=Digit>
						<away=Word><away_score=Digit>
	<token: Word>		\D+
	<token: Digit>		\d
/;

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
			if ($line =~ /^#.*/) { # date hack
				if ($line =~ $date_parser) {
					do_dates ($/{Date});
				}
			} elsif ($line =~ $game_parser) {
				do_games ($/{Results}, \@games);
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

#	Hack to recognise a date - add a # synbol to the start of each day
	$$dataref =~ s/((Fri|Sat|Sun|Mon|Tue|Wed|Thu).*day )/#$1/g;
#	Add new line after each month
	$$dataref =~ s/(February|March|April|May)/$1\n/g;

	my @lines = split /\n/, $$dataref;
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
	$hash->{home} = $euro_teams->{ $hash->{home} } if defined $euro_teams->{ $hash->{home} };
	$hash->{away} = $euro_teams->{ $hash->{away} } if defined $euro_teams->{ $hash->{away} };

	push @$games, {
		date => $date,
		home_team => $hash->{home},
		away_team => $hash->{away},
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

=head

#	Without Regexp::Grammars

my $my_date_parser = qr/
	\#				# date_hack
	\D+\s			# day
	(?<date>\d\d?)	# date
	\w\w\s			# date end (st,nd,rd,th)
	(?<month>\w+)	# month
/x;

if ($line =~ $my_date_parser) {
	do_my_dates ( $+{date}, $+{month} );
}

sub do_my_dates {
	my ($my_date, $my_month) = @_;

	my $dt = sprintf "%02d", $my_date;
	my $month = $month_names->{ $my_month };
	$date = "$dt/$month/$year";
}
=cut
