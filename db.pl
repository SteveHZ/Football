#	db.pl 24-25/02/18, 02/03/18, 16/03/18, 27/04-03/05/18
#	v1.1 07-09/01/19, v1.2 28/06/19, v1.21 25/11/19

#BEGIN { $ENV{PERL_KEYWORD_TESTING} = 1;}
use strict;
use warnings;

use TryCatch;
use List::Util qw(reduce min);
use MyLib qw(var_precision);

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
			my $games = $sth->fetchall_arrayref ({});
			show_all ($team, $games, $data);
		} catch {
			print "Usage : (team name) -[ha] -[wld]";
		}
	}
	print "\n";
}

sub show_all {
	my ($team, $games, $data) = @_;
	for my $game (@$games) {
		if ($game->{hometeam} =~ /$team.*/) {
			show_homes ($game);
		} else {
			show_aways ($game);
		}
	}
	show_info ($team, $games, $data);
}

sub show_homes {
	my $game = shift;
	my $odds_column = $data->{column}.'h';

	print "\n$game->{date} ";
	printf "%-20s H  ", $game->{awayteam};
	print "$game->{fthg}-$game->{ftag}  ";
	printf "%5.2f", $game->{$odds_column};
}

sub show_aways {
	my $game = shift;
	my $odds_column = $data->{column}.'a';

	print "\n$game->{date} ";
	printf "%-20s A  ", $game->{hometeam};
	print "$game->{ftag}-$game->{fthg}  ";
	printf "%5.2f", $game->{$odds_column};
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

# functional analysis

sub show_info {
	my ($team, $games, $data) = @_;
	my $num_games = scalar @$games;
	my $wins = total_wins ($team, $games);
	my $return = total_return ($team, $games, $data);
	my $overs = do_overs ($team, $games);
	my $last_six_overs = do_last_six_overs ($team, $games, $num_games);

	print "\n\nGames = ". $num_games;
	print "\nTotal Wins = ". $wins;
	print "\nPercentage Wins = ". percentage ($wins, $num_games);
	print "\nTotal Return = ".chr(156). $return;
	print "\nPercentage Return = ". returns ($return, $num_games);
	print "\nOver 2.5 = ".$overs;
	print "\nLast Six Overs = ".$last_six_overs;
}

sub total_return {
	my ($team, $games, $data) = @_;
	my $odds_cols = { h => $data->{column}.'h', a => $data->{column}.'a' };
	return sprintf "%.2f",
		reduce { $a + $b }
		map { calc_return ($team, $_, $odds_cols) }
		@$games;
}

sub calc_return {
	my ($team, $game, $odds_cols) = @_;
	return $game->{ $odds_cols->{h} } if $team eq $game->{hometeam} && $game->{ftr} eq 'H';
	return $game->{ $odds_cols->{a} } if $team eq $game->{awayteam} && $game->{ftr} eq 'A';
	return 0;
}

sub total_wins {
	my ($team, $games) = @_;
	return reduce { $a + $b }
		   map { is_win ($team, $_) }
		   @$games;
}

sub is_win {
	my ($team, $game) = @_;
	return 1 if $team eq $game->{hometeam} && $game->{ftr} eq 'H';
	return 1 if $team eq $game->{awayteam} && $game->{ftr} eq 'A';
	return 0;
}

sub do_overs {
	my ($team, $games) = @_;
	my $overs = reduce { $a + $b }
				map { is_over ($team, $_) }
				@$games;
	return percentage ($overs, scalar @$games);
}

sub do_last_six_overs {
	my ($team, $games, $num_games) = @_;
	my $offset = min (6, $num_games);
	my $overs = reduce { $a + $b }
				map { is_over ($team, $_) }
				splice @$games, $offset * -1;
	return percentage ($overs, $offset);
}

sub is_over {
	my ($team, $game) = @_;
	return 1 if $game->{fthg} + $game->{ftag} > 2;
	return 0;
}

sub percentage	{ percent (( $_[0]/$_[1] ) * 100) };
sub returns		{ percent  ( $_[0]/$_[1] ) };

sub percent {
	my $val = shift;
	return sprintf "%.*f%%", var_precision ($val), $val;
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
