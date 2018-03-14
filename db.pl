#!	C:/Strawberry/perl/bin

#	db.pl 24-25/02/18, 02/03/18

use strict;
use warnings;

use Football::DBModel;
use Football::Globals qw( @csv_leagues @euro_csv_lgs @summer_leagues);

my $query_dispatch = {
	'h' => \&Football::DBModel::get_homes,
	'a' => \&Football::DBModel::get_aways,
};
my $output_dispatch = {
	'h' => \&print_homes,
	'a' => \&print_aways,
};

my $euro = 0;
if (defined $ARGV [0]) {
	$euro = 1 if $ARGV[0] eq "-e";
	$euro = 2 if $ARGV[0] eq "-s";
}
my @funcs = (\&get_uk_data, \&get_euro_data, \&get_summer_data);
my $data = $funcs[$euro]->();

my $model = Football::DBModel->new (data => $data);
my $leagues = $model->build_leagues ($data->{leagues});

print "\n";
while (my ($team, $ha) = get_cmdline ()) {
	last if $team eq 'x';
	die "Usage : (team name) [-h|-a]" unless $ha =~ /[h|a]/;

	my $league = $model->find_league ($team, $leagues, $data->{leagues});
	if ($league) {
		get_results ($model, $league, $team, $ha);
	} else {
		print "\nUnknown error !!!\n";
	}
}

sub get_cmdline {
	print "\nDB > ";
	chomp (my $in = <STDIN>);
	my ($team, $ha) = split (' -', $in);
	return ($team, $ha);
}

sub get_results {
	my ($model, $league, $team, $ha) = @_;

	my $query = $query_dispatch->{$ha}->($model, $league);
	my $sth = $model->dbh->prepare ($query)
		or die "Couldn't prepare statement : ".$model->dbh->errstr;
	$sth->execute ($team);

	while (my $row = $sth->fetchrow_hashref) {
		$output_dispatch->{$ha}->($row);
	}
	print "\n";
}

#	called by $output_dispatch

sub print_homes {
	my $row = shift;

	my $column = $data->{column}.'H';
	print "\n$row->{Date} ";
	printf "%-20s", $row->{AwayTeam};
	print "$row->{FTHG}-$row->{FTAG}  $row->{$column}";
}

sub print_aways {
	my $row = shift;

	my $column = $data->{column}.'A';
	print "\n$row->{Date} ";
	printf "%-20s", $row->{HomeTeam};
	print "$row->{FTHG}-$row->{FTAG}  $row->{$column}";
}

sub get_uk_data {
	return {
		leagues => \@csv_leagues,
		column => 'B365',
		path => 'data',
	}
}

sub get_euro_data {
	return {
		leagues => \@euro_csv_lgs,
		column => 'B365',
		path => 'data/Euro',
	}
}

sub get_summer_data {
	return {
		leagues => \@summer_leagues,
		column => 'Avg',
		path => 'data/Euro',
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