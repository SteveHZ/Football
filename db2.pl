#!	C:/Strawberry/perl/bin

#	db.pl 24-25/02/18, 02/03/18, 16/03/18

use strict;
use warnings;
use Data::Dumper;

use lib 'C:/Mine/perl/Football';
use MyLib qw(prompt);
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
while (my ($cmd_line) = prompt ("DB-$data->{model}")) {
	last if $cmd_line eq 'x';
	get_results ($model, $cmd_line);
}

sub get_results {
	my ($model, $cmd_line) = @_;

	my ($team, $options) = $model->do_cmd_line ($cmd_line);
print "\noptions = ".Dumper $options;
	my $ha = $model->get_homeaway ($options);
	my $league = $model->find_league ($team, $leagues,  $data->{leagues});
	my $query = $model->build_query ($team, $options);
	my $sth = $model->do_query ($league, $query);

	while (my $row = $sth->fetchrow_hashref) {
#		print_all ($row);
		$output_dispatch->{$ha}->($row);
	}
	print "\n";
}

#	called by $output_dispatch

#=head
sub print_all {
	my $row = shift;

	my $column = $data->{column}.'a';
	print "\n$row->{date} ";
	printf "%-20s", $row->{hometeam};
	printf "%-20s", $row->{awayteam};
	print "$row->{fthg}-$row->{ftag}  $row->{$column}";
}

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
#=cut

=head
sub print_all {
	my ($row, $column) = @_;

	my $column = $data->{column}.'a';
	print "\n$row->{date} ";
	printf "%-20s", $row->{hometeam};
	printf "%-20s", $row->{awayteam};
	print "$row->{fthg}-$row->{ftag}  $row->{$column}";
}

sub print_homes {
	my $row = shift;

	my $column = $data->{column}.'H';
	print_all ($row, $column); #?? could also do this for print_aways and print_draws ????
}

sub print_aways {
	my $row = shift;

	my $column = $data->{column}.'A';
	print_all ($row, $column); #?? could also do this for print_aways and print_draws ????
}
=cut

sub get_uk_data {
	return {
		leagues => \@csv_leagues,
		column => 'b365',
		path => 'data',
		model => 'UK',
	}
}

sub get_euro_data {
	return {
		leagues => \@euro_csv_lgs,
		column => 'b365',
		path => 'data/Euro',
		model => 'Euro',
	}
}

sub get_summer_data {
	return {
		leagues => \@summer_leagues,
		column => 'avg',
		path => 'data/Summer',
		model => 'Summer',
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