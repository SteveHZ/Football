#	db.pl 24-25/02/18, 02/03/18, 16/03/18, 27/04-03/05/18
#	v1.1 07-09/01/19

#BEGIN { $ENV{PERL_KEYWORD_TESTING} = 1;}
use strict;
use warnings;
use TryCatch;

use MyKeyword qw(TESTING);
TESTING { use Data::Dumper; }

use lib 'C:/Mine/perl/Football';
use MyLib qw(prompt);
use Football::DBModel;
use Football::Globals qw( @csv_leagues @euro_csv_lgs @summer_csv_leagues );

my $euro = 0;
if (defined $ARGV [0]) {
	$euro = 1 if $ARGV[0] eq '-e';
	$euro = 2 if $ARGV[0] eq '-s';
}

my @funcs = (
	sub { get_uk_data		(@_) },
	sub { get_euro_data		(@_) },
	sub { get_summer_data	(@_) },
);
my $data = $funcs[$euro]->();
my $model = Football::DBModel->new (data => $data);

my $output_dispatch = {
	'h'  => sub { show_homes (@_) },
	'a'  => sub { show_aways (@_) },
	'ha' => sub { show_all   (@_) },
};

print "\n";
while (my $cmd_line = prompt ("DB-$data->{model}")) {
	last if lc $cmd_line eq 'x';
	get_results ($model, $cmd_line);
}

sub get_results {
	my ($model, $cmd_line) = @_;

	my ($team, $options) = $model->do_cmd_line ($cmd_line);
	my $ha = $model->get_homeaway ($options);
	my $league = $model->find_league ($team);
	if ($league eq 0) {
		print "\nUnknown team name. Please try again...";
	} else {
		try {
			my $sth = $model->do_query ($league, $team, $options);
			while (my $row = $sth->fetchrow_hashref) {
				$output_dispatch->{$ha}->($row, $team);
			}
		} catch {
			print "\nUsage : (team name) -[ha] -[wld]";
		}
	}
	print "\n";
}

#	called by $output_dispatch

sub show_all {
	my ($row, $team) = @_;

	if ($row->{hometeam} =~ /$team.*/) {
		show_homes ($row);
	} else {
		show_aways ($row);
	}
}

sub show_homes {
	my $row = shift;
	my $odds_column = $data->{column}.'h';

	print "\n$row->{date} ";
	printf "%-20s H  ", $row->{awayteam};
	print "$row->{fthg}-$row->{ftag}  ";
	printf "%5.2f", $row->{$odds_column};
}

sub show_aways {
	my $row = shift;
	my $odds_column = $data->{column}.'a';

	print "\n$row->{date} ";
	printf "%-20s A  ", $row->{hometeam};
	print "$row->{ftag}-$row->{fthg}  ";
	printf "%5.2f", $row->{$odds_column};
}

#	data functions

sub get_uk_data {
	return {
		leagues	=> \@csv_leagues,
		column	=> 'b365',
		path	=> 'data',
		model	=> 'UK',
	}
}

sub get_euro_data {
	return {
		leagues	=> \@euro_csv_lgs,
		column	=> 'b365',
		path	=> 'data/Euro',
		model	=> 'Euro',
	}
}

sub get_summer_data {
	return {
		leagues	=> \@summer_csv_leagues,
		column	=> 'avg',
		path	=> 'data/Summer',
		model	=> 'Summer',
	}
}

=pod

=head1 NAME

db.pl

=head1 SYNOPSIS

 perl db.pl
 Run as db.pl for UK leagues
 Run as db.pl -e for European winter leagues
 Run as db.pl -s for European and US summer leagues

=head1 DESCRIPTION

Show all home or away wins with odds

=head1 AUTHOR

Steve Hope 2018

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
