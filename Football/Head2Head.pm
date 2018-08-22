package Football::Head2Head;

# 	Football::Head2Head.pm 21/02/16
#	v2 10-11/04/16

use strict;
use warnings;

use MyJSON qw(read_json write_json);
use Football::Table;
use Football::Season;

my $path = 'C:/Mine/perl/Football/data/';
my $historical_path = 'C:/Mine/perl/Football/data/historical/';
my $h2h_file = $path.'head2head.json';

sub new {
	my ($class, $leagues, $all_teams, $seasons) = @_;
	
	my $self = {};
	unless ($seasons) {
		$self->{hash} = read_json ($h2h_file);
	} elsif ($all_teams) {
		$self->{hash} = create ($leagues, $all_teams, $seasons);
	} else {
		die "Problem creating Head2Head object !!";
	}
	bless $self, $class;
	return $self;
}

sub fetch {
	my ($self, $league, $home, $away) = @_;
	return \@{ $self->{hash}->{$league}->{$home}->{$away} };;
}

sub create {
	my ($leagues, $all_teams, $seasons) = @_;
	
	csv_to_json ($leagues, $seasons);
	my $teams = create_hash ($leagues, $all_teams, $seasons);
	return build_head2head ($leagues, $teams, $seasons);
}

sub csv_to_json {
	my ($leagues, $seasons) = @_;
	my ($csv_file, $json_file);
		
	for my $league (@$leagues) {
		for my $season (@ { $seasons->{$league} }) {
			print "\nCSV to JSON - Updating $league - $season...";
			$csv_file = $historical_path.$league.'/'.$season.'.csv';
			my $games = read_csv_file ($csv_file);

			$json_file = $historical_path.$league.'/'.$season.'.json';
			write_json ($json_file, $games);
		}
	}
}

sub create_hash {
	my ($leagues, $all_teams, $seasons) = @_;
	my $teams = {};
	
	print "\n";
	for my $league (@$leagues) {
		print "\nCreating hash for $league...";
		for my $home (@ {$all_teams->{$league} }) {
			for my $away (@ {$all_teams->{$league} }) {
				for my $season (@{ $seasons->{h2h_seasons} }) {
					@{ $teams->{$league}->{$home}->{$away} } = qw(X X X X X X) unless $home eq $away;
				}
			}
		}
	}
	return $teams;
}

sub build_head2head {
	my ($leagues, $teams, $seasons) = @_;
	my $idx;
	
	print "\n";
	for my $league (@$leagues) {
		for my $season (@{ $seasons->{h2h_seasons} }) {
			print "\nHead To Head - Updating $league - $season...";
			my $json_file = $historical_path.$league.'/'.$season.'.json';
			my $games = read_json ($json_file);

			for my $game (@$games) {
				my $home_team = $game->{home_team};
				my $away_team = $game->{away_team};
				my $result = get_result ($game->{home_score}, $game->{away_score});
				if (exists ($teams->{$league}->{$home_team}) && 
					exists ($teams->{$league}->{$away_team} )) {
					$idx = $season - @{ $seasons->{h2h_seasons} }[0];
					$teams->{$league}->{$home_team}->{$away_team}->[$idx] = $result;
				}
			}
		}
	}
	my $json_file = $path.'head2head.json';
	write_json ($json_file, $teams);
	return $teams;
}

sub get_result {
	my ($home, $away) = @_;
	
	return 'H' if $home > $away;
	return 'A' if $home < $away;
	return 'D';
}

sub read_csv_file {
	my $csv_file = shift;
	my @all_games = ();
	my $week = 0;
	my ($date, $home, $away, $h, $a);
	my ($week_counter, $junk, @junk);
	
	open (my $fh, '<', $csv_file) or die ("Can't find $csv_file");
	my $line = <$fh>; # read and ignore the first line
		
	while ($line = <$fh>) {
		($junk, $date, $home, $away, $h, $a, @junk) = split (/,/, $line);
		last if $junk eq ""; # don't remove !!!
		if ($week > 0) {
			$week = $week_counter->check ($date);
		} else {
			$week = 1;
			$week_counter = Football::Season->new ($date);
		}
		push ( @all_games, {
			date => $date,
			week => $week,
			home_team => $home,
			away_team => $away,
			home_score => $h,
			away_score => $a,
		});
	}
	close $fh;
	return \@all_games;
}

1;
