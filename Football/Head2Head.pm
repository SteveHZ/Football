package Football::Head2Head;

# 	Football::Head2Head.pm 21/02/16

use strict;
use warnings;

use MyJSON qw(read_json write_json);
use Football::Table;
use Football::Season;

my $path = 'C:/Mine/perl/Football/data/';
my $old_path = 'C:/Mine/perl/Football/data/historical/';
my $h2h_file = $path.'head2head.json';

sub new {
	my ($class, $seasons, $all_teams) = @_;
	
	my $self = {};
	unless ($seasons) {
		$self->{hash} = read_json ($h2h_file);
	} elsif ($all_teams) {
			$self->{hash} = create ($seasons, $all_teams);
	} else {
		die "Problem creating Head2Head object !!";
	}
	bless $self, $class;
	return $self;
}

sub fetch {
	my ($self, $home, $away) = @_;
	return \@{ $self->{hash}->{$home}->{$away} };
}

sub create {
	my ($seasons, $all_teams) = @_;
	
	csv_to_json ($seasons);
	my $teams = create_hash ($seasons, $all_teams);
	return build_head2head ($seasons, $teams);
}

sub csv_to_json {
	my $seasons = shift;
	
	my ($csv_file, $json_file);
	my ($date, $home, $away, $h, $a);
	my ($junk, @junk);
	my $week_counter;
		
	for my $season (@{ $seasons->{all_seasons} }) {
		my @all_games = ();
		my $week = 0;
		
		print "\nCSV to JSON - Updating $season...";
		$csv_file = $old_path.$season.'.csv';

		open (my $fh, '<', $csv_file) or die ("Can't find $season.csv");
		my $line = <$fh>; # read and ignore the first line
		
		while ($line = <$fh>) {
			($junk, $date, $home, $away, $h, $a, @junk) = split (/,/, $line);
			last if $junk eq ""; # earlier files have extra lines with just commas
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
		$json_file = $old_path.$season.'.json';
		write_json ($json_file, \@all_games);
	}
}

sub create_hash {
	my ($seasons, $all_teams) = @_;
	my $teams = {};
	
	for my $home (@$all_teams) {
#		print "\nWriting $home";
		for my $away (@$all_teams) {
			for my $season (@{ $seasons->{h2h_seasons} }) {
				@{ $teams->{$home}->{$away} } = qw(X X X X X X) unless $home eq $away;
			}
		}
	}
	my $json_file = $path.'head2head.json';
	write_json ($json_file, $teams);
	return $teams;
}

sub build_head2head {
	my ($seasons, $teams) = @_;
	my $idx;
	
	print "\n";
	for my $season (@{ $seasons->{h2h_seasons} }) {
		print "\nHead To Head - Updating $season...";
		my $json_file = $old_path.$season.'.json';
		my $games = read_json ($json_file);

		for my $game (@$games) {
			my $home_team = $game->{home_team};
			my $away_team = $game->{away_team};
			my $result = get_result ($game->{home_score}, $game->{away_score});
			if (exists ($teams->{$home_team}) && exists ($teams->{$away_team} )) {
				$idx = $season - @{ $seasons->{h2h_seasons} }[0];
				$teams->{$home_team}->{$away_team}->[$idx] = $result;
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
	return 'D';		#	if $home > 0;#	return 'N';
}

1;
