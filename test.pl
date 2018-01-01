#!	C:/Strawberry/perl/bin

#	football/test.pl 31/01/16

use strict;
use warnings;
use v5.22;

use Excel::Writer::XLSX;
use Spreadsheet::Read qw(ReadData);
#use Data::Dumper;

use Team;
use Football::Model;
use Football::View;
use Football::API;

my $path = 'C:/Mine/perl/Football/data/';
#my $premdata = $path.'E0.csv';
#my $json_file = $path.'prem 2014-15.json';
my $xlsx_file = $path.'teams.xlsx';

#my $games;
#my $teams;
#my @all_teams;
#my $model;

main ();

sub main {
	my $model = Football::Model->new ();
	my $view = Football::View->new ();

	my $dispatch = {
		0 => \&homes_test,
		1 => \&update,
		2 => \&read_from_json,
		9 => \&quit,
	};

	my $arg = $ARGV[0] // "";
	my $games = ($arg eq "-u") ? $model->update () :
								 $model->read_from_json ();

	my $teams = $model->build_data ($games);

#	$view->print_all_games ($games);

	my $choice = $view->menu ();
	$dispatch->{$choice}->();
#	homes_test ($model, $teams);

#	print_out ($games);
#	my $teams = _build_data ($games);
#	$teams = build_data ($games);
#	write_xlsx ($games, $teams);

#	my $teams2 = read_xlsx ();
#	print Dumper ($teams2);
}

sub homes_test {
	my ($model, $teams) = @_;
#	my $points = {'W'=>3,'D'=>1,'N'=>1,'L'=>0,};
#	my $total_points = 0;
	
	for my $team ($model->return_all_teams ()) {
#	for my $team (@all_teams) {
		printf "\n%-15s :", $team;
#		print " $_"  for (get_homes ($team));
		print " $_"  for ($teams->{$team}->get_homes ());
	}
	<STDIN>;
	for my $team ($model->return_all_teams ()) {
#	for my $team (@all_teams) {
		my @results = ();
		print "\n\n$team :";
		my @temp = $teams->{$team}->get_full_homes ();
#		my @temp = get_full_homes ($team);
		for my $list (@temp) {
			printf "\n%s : %-15s  %s  %s", $list->{date}, $list->{opponent}, $list->{result}, $list->{score};
			push @results, $list->{result};
		}
#		print "\n";
#		print "$_ " for @results;
		<STDIN>;
	}
}

sub write_xlsx {
	my ($games, $teams) = @_;

	my $workbook = Excel::Writer::XLSX->new ($xlsx_file)
		or die "Problems creating new Excel file: $!";
	my $format = $workbook->add_format(
		align => 'center',
		bg_color => '#FFC7CE',
		color    => 'blue',
	);

#	for my $team (@all_teams) {
	for my $team (get_all_teams ($games)) {
		print "\nWriting data for $team...";
		my $worksheet = $workbook->add_worksheet ($team);
		$worksheet->set_column ('A:B', 20);
		$worksheet->set_column ('B:C', 10);

		my $row = 0;
		my $next = $teams->{$team}->iterator ();
		while (my $list = $next->()) {
#		for my $list (@{$teams->{$team}->{games}} ) {
			$worksheet->write ($row, 0, $list->{date}, $format);
			$worksheet->write ($row, 1, $list->{opponent}, $format);
			$worksheet->write ($row, 2, $list->{home_away}, $format);
			$worksheet->write ($row, 3, $list->{result}, $format);
			$worksheet->write ($row, 4, $list->{score}, $format);
			$row++;
		}
		print "Done";
	}
	$workbook->close ();
}

sub read_xlsx {
	my $book = ReadData ($xlsx_file);
	my $sheets = @$book[0]->{sheets};
	my $teams;

	for my $sheet (1...$sheets) {
		my $name = @$book[$sheet]->{label};
		$teams->{name} = $name;
		$teams->{$name}->{games} = ();
		print "\n\n". uc ($name). " :";
		
		my @rows = Spreadsheet::Read::rows ( @$book[$sheet] );
		for my $i (0 .. $#rows) {
			my $game = {
				date => $rows [$i][0],
				opponent => $rows [$i][1],
				home_away => $rows [$i][2],
				result => $rows [$i][3],
				score => $rows [$i][4],
			};

#create new Team object here
			push (@ {$teams->{$name}->{games} }, $game);
			printf "\n%s : %-15s %s %s %s", $game->{date}, $game->{opponent}, $game->{home_away}, $game->{result}, $game->{score};
		}
		<STDIN>;
	}
	return $teams;
}

sub quit {
	exit(0);
}

=head2
sub old_main {
#	my $dispatch = {
#		1 => \&update,
#		2 => \&read_from_json,
#		9 => \&quit,
#	};
#	my $choice = menu ();
#	my $games = $dispatch->{$choice}->();

	my $games = read_from_json ();
	print_out ($games);
	my $teams = build_data ($games);
	write_xslx ($games, $teams);
}
sub menu {
	print "\n1 = Update";
	print "\n2 = Read from JSON";
	print "\n9 = Quit";
	print "\n\n>";
	chomp (my $choice = <STDIN>);
	return $choice;
}
sub quit {
	exit (0);
}
sub build_data {
	my $games = shift;
	my $teams;

	@all_teams = get_all_teams ($games);

	print "\n\nAll teams :";
	for (@all_teams) {
		$teams->{$_} = Team->new($_);
		print "\n$_";
		$teams->{name} = $_;
		$teams->{$_}->{games} = ();
	}

	for my $game (@$games) {
		my $home_team = $game->{home_team};
		my $away_team = $game->{away_team};
		my ($home_result, $away_result) = get_result ($game->{home_score}, $game->{away_score});
		my $home = {
			date => $game->{date},
			opponent => $game->{away_team},
			home_away => 'H',
			result => $home_result,
			score => $game->{home_score}.'-'.$game->{away_score},
		};
		my $away = {
			date => $game->{date},
			opponent => $game->{home_team},
			home_away => 'A',
			result => $away_result,
			score => $game->{away_score}.'-'.$game->{home_score}
		};

#$team->{$home_team}->add ($home);
#$team->{$away_team}->add ($away);
		push (@ {$teams->{$home_team}->{games} }, $home);
		push (@ {$teams->{$away_team}->{games} }, $away);
	}

	for my $team (@all_teams) {
		print "\n\n$team :";
		for my $list (@{$teams->{$team}->{games}} ) {
			printf "\n%s : %-15s %s %-6s %s", $list->{date}, $list->{opponent}, $list->{home_away}, $list->{result}, $list->{score};
		}
	}
	return $teams;
}
sub _build_data {
	my $games = shift;
	my $teams = {};

	@all_teams = get_all_teams ($games);

	for (@all_teams) {
		$teams->{$_} = Team->new ();
	}

	for my $game (@$games) {
		my $home_team = $game->{home_team};
		my $away_team = $game->{away_team};
		my ($home_result, $away_result) = get_result ($game->{home_score}, $game->{away_score});
		my $home = {
			date => $game->{date},
			opponent => $game->{away_team},
			home_away => 'H',
			result => $home_result,
			score => $game->{home_score}.'-'.$game->{away_score},
		};
		my $away = {
			date => $game->{date},
			opponent => $game->{home_team},
			home_away => 'A',
			result => $away_result,
			score => $game->{away_score}.'-'.$game->{home_score}
		};
		$teams->{$home_team}->add ($home);
		$teams->{$away_team}->add ($away);
	}

	for my $team (@all_teams) {
		print "\n\n$team :";
		my $next = $teams->{$team}->iterator ();
		while (my $list = $next->()) {
			printf "\n%s : %-15s %s %-6s %s", $list->{date}, $list->{opponent}, $list->{home_away}, $list->{result}, $list->{score};
		}
	}
	return $teams;
}

sub get_full_homes {
	my ($team, $num_games) = @_;
	my ($start, $end);
	
	$num_games //= 6;
#	my @list = grep {$_->{home_away} eq 'H'} @{$teams->{$team}->{games}};
#	$end = scalar @list - 1;
#	$start = $end - ($num_games - 1);

#	return splice (@list, $start, $end);
}

sub get_homes {
	my ($team, $num_games) = @_;
	my @results = ();
	
	$num_games //= 6;
	my @temp = get_full_homes ($team, $num_games);
	push @results, $_->{result} for @temp;
	return @results;
}
sub unique {
	my (%hash) = ( order => "asc", @_ );

	my $sort_func = ($hash{order} eq "asc") ?
		sub { $a cmp $b } : sub { $b cmp $a };

	return sort $sort_func
		keys %{{ map { $_->{$hash{field}}  => 1 } @{$hash{db}} }};
}

sub where {
	my (%hash) = ( order => "asc", @_ );

	my $sort_func = ($hash{order} eq "asc") ?
		sub { $a->{$hash{sort_by}} cmp $b->{$hash{sort_by}} } :
		sub { $b->{$hash{sort_by}} cmp $a->{$hash{sort_by}} };

	return sort $sort_func
		grep { $_->{$hash{field}} eq $hash{data} } @{$hash{db}};
}
sub get_result {
	my ($home, $away) = @_;
	
	return ('W','L') if $home > $away;
	return ('L','W') if $away > $home;
	return ('D','D') if $home > 0;
	return ('N','N');
#	return ('D','D');
}
sub get_all_teams {
	my $games = shift;
	return unique (
		db => $games,
		field => "home_team",
	);
}	

sub print_out {
	my $games = shift;
		
	foreach my $game (@$games) {
		state $count = 1;
		printf "\n%3d : %s %-15s %-15s %d-%d",	$count ++, $game->{date},
												$game->{home_team}, $game->{away_team},
												$game->{home_score}, $game->{away_score};
	
	}
}

=cut
