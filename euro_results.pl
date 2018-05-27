#!	C:/Strawberry/perl/bin

#	euro_results.pl 16-20/07/17
#	without Regexp::Grammars 28-30/07/17
#	added split_team_names 30/09/17
#	use check_rename 13/01/18

#	Run euro_scrape.pl to retrieve results data from BBC website,
#	run this script to write to csv files then run update_euro.pl to create season.json.

use strict;
use warnings;

use lib 'C:/Mine/perl/Football';
use MyDate qw( $month_names );
use Football::Globals qw( $euro_season );
use Euro::Rename qw( check_rename );

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

my $date;
my $year = $euro_season - 2000;
my $in_path = "C:/Mine/perl/Football/data/Euro/scraped/";
my $out_path = "C:/Mine/perl/Football/data/Euro/cleaned/";

my %filenames = (
#	"Irish" 	=> [ "Ireland Feb", "Ireland March", "Ireland April", "Ireland May" ],
#	"Norwegian"	=> [ "Norway April", "Norway May" ],
#	"Swedish"	=> [ "Sweden April", "Sweden May" ],
#	"USA"		=> [ "USA March", "USA April", "USA May" ],
#	"Welsh"		=> [ "Welsh August", "Welsh Sept" ],
	"N Irish" 	=> [ "NI August", "NI Sept" ],
	"Highland" 	=> [ "HL July", "HL August", "HL Sept", "HL Oct" ],
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
	$$dataref =~ s/(January|February|March|April|May|June|July|August|September|October|November|December)/$1\n/g;

	return [ split /\n/, $$dataref ];
}

sub do_dates {
	my $hash = shift;

	my $dt = sprintf "%02d", $hash->{date};
	my $month = $month_names->{ $hash->{month} };
	$date = "$dt/$month/$year";
}

sub do_games {
	my ($hash, $games) = @_;

#	Remove doubled team names
	my ($home, $away) = split_team_names ($hash);
	
#	Check for and rename teams with Unicode characters
	$home = check_rename ($home);
	$away = check_rename ($away);
	
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

=pod

=head1 NAME

euro_results.pl

=head1 SYNOPSIS

perl euro_results.pl

=head1 DESCRIPTION

 Run euro_scrape.pl to retrieve results data from BBC website,
 Run this script to write to csv files then run update_euro.pl to create season.json.

=head1 AUTHOR

Steve Hope 2017

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut