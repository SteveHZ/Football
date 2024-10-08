package Football::Model;

#	Football::Model.pm 03/02/16 - 14/03/16
# 	v2.0 23-28/03/16, v2.01 Mouse 04/05/16, v2.02 Football_Data_Model 27/05/16 v2.03 26-27/07/16
#	v2.06 Moo 01/10/16	v2.07 with Football::Shared_Model 18-19/01/17
#	v2.08 refactored 19-21/12/18, v2.09 Mu 07/05/19, amended back to Moo 18/07/24

use lib 'C:/Mine/perl/Football';
use Football::League;
use Football::Reports::GoalDifference;
use Football::Reports::Recent_GoalDifference;
use Football::Reports::LeaguePlaces;
use Football::Reports::Head2Head;
use Football::Globals qw( @league_names @csv_leagues );
use MyKeyword qw(TESTING); # for model.t

use Syntax::Keyword::Gather;

use Moo;
use namespace::clean;

has 'league_names' => (is => 'ro', default => sub { \@league_names} );
has 'csv_leagues' => (is => 'ro', default => sub { \@csv_leagues} );
has 'leagues' => (is => 'ro', default => sub { [] } );
has 'fixtures' => (is => 'ro', default => sub { [] } );

has 'season_data' => (is =>'ro', default => '');
has 'test_season_data' => (is =>'ro', default => '');

# pre-declare these with default values to use Football_IO role
has 'path' => (is =>'ro', default => '');
has 'fixtures_file' => (is =>'rw', default => '');
has 'test_fixtures_file' => (is =>'ro', default => '');
has 'model_name' => (is =>'ro', default => 'uk');

with 'Roles::MyJSON',
'Football::Roles::Quick_Model',
'Football::Roles::Shared_Model',
'Football::Roles::Football_IO_Role',
'Football::Roles::Expect_Data',;

sub BUILD {
	my $self = shift;
	$self->{model_name} = "UK";
	$self->{leagues} = [];
	$self->{league_idx} = $self->build_league_idx ($self->{league_names});

	$self->{path} = 'C:/Mine/perl/Football/data/';
	$self->{fixtures_file} = $self->{path}.'fixtures.csv';
	$self->{season_data} = $self->{path}.'season.json';
	$self->{teams_file} = $self->{path}.'teams.json';

	$self->{test_path} = 'C:/Mine/perl/Football/t/test data/';
	$self->{test_teams_file} = $self->{test_path}.'teams.json';
	$self->{test_season_data} = $self->{test_path}.'season.json';
	$self->{test_fixtures_file} = $self->{test_path}.'football fixtures.csv';
}

sub build_leagues {
	my ($self, $games) = @_;
	my $teams = $self->read_json ( $self->{teams_file} );
	TESTING { $teams = $self->read_json ( $self->{test_teams_file} ); }

	for my $league ($self->league_names->@*) {
#		die "No games played in $league" if scalar $games->{$league}->@* == 0);
		push ( $self->leagues->@*, Football::League->new (
			name		=> $league,
			games 		=> $games->{$league},
			team_list	=> $teams->{$league},
		));
	}
	return $self->leagues;
}

sub do_goal_difference {
	my ($self, $fixtures, $teams) = @_;

	my $goal_diff = Football::Reports::GoalDifference->new ();
	for my $league_fixtures (@$fixtures) {
		my $league_name = $league_fixtures->{league};
		my $idx = $self->get_league_idx ($league_name);
		my $league = $self->leagues->[$idx];

		for my $game ($league_fixtures->{games}->@*) {
			my $home_diff = $league->goal_diff ($game->{home_team});
			my $away_diff = $league->goal_diff ($game->{away_team});

			$game->{goal_difference} = $home_diff - $away_diff;
			$game->{gd_results} = $self->fetch_goal_difference ($goal_diff, $league_name, $game->{goal_difference});
		}
	}
	return $fixtures;
}

sub do_recent_goal_difference {
	my ($self, $fixtures, $teams) = @_;

	my $goal_diff = Football::Reports::Recent_GoalDifference->new ();
	for my $league_fixtures (@$fixtures) {
		my $league_name = $league_fixtures->{league};
		my $idx = $self->get_league_idx ($league_name);
		my $league = $self->leagues->[$idx];

		for my $game ($league_fixtures->{games}->@*) {
			my $home_diff = $league->recent_goal_diff ($game->{home_team});
			my $away_diff = $league->recent_goal_diff ($game->{away_team});

			$game->{recent_goal_difference} = $home_diff - $away_diff;
			$game->{rgd_results} = $self->fetch_goal_difference ($goal_diff, $league_name, $game->{recent_goal_difference});
		}
	}
	return $fixtures;
}

#	Euro and Summer models override this using Football::Roles::Fetch_Goal_Diff
sub fetch_goal_difference {
	my ($self, $goal_diff_obj, $league_name, $goal_difference) = @_;
	return $goal_diff_obj->fetch_array ($league_name, $goal_difference);
}

sub do_league_places {
	my ($self, $fixtures, $teams) = @_;

	my $league_places = Football::Reports::LeaguePlaces->new ();
	for my $league_fixtures (@$fixtures) {
		my $league_name = $league_fixtures->{league};
		my $idx = $self->get_league_idx ($league_name);
		my $league = $self->leagues->[$idx];

		for my $game ($league_fixtures->{games}->@*) {
			$game->{home_pos} = $league->position ($game->{home_team});
			$game->{away_pos} = $league->position ($game->{away_team});
			$game->{results} = $league_places->fetch_array ($league_name, $game->{home_pos}, $game->{away_pos});
		}
	}
	return $fixtures;
}

sub do_head2head {
	my ($self, $fixtures) = @_;

	my $h2h = Football::Reports::Head2Head->new ();
	for my $league (@$fixtures) {
		my $league_name = $league->{league};

		for my $game ($league->{games}->@*) {
			my $home = $game->{home_team};
			my $away = $game->{away_team};
			$game->{head2head} = $h2h->fetch ($league_name, $home, $away);

			my ($home_points, $away_points) = $h2h->calc_points ($game->{head2head});
			$game->{home_h2h} = $home_points;
			$game->{away_h2h} = $away_points;
		}
	}
	return $fixtures;
}


sub do_recent_draws {
	my ($self, $fixtures) = @_;

	return [
		sort {
			$b->{game}->{draws} <=> $a->{game}->{draws}
			or $b->{game}->{home_draws} <=> $a->{game}->{home_draws}
			or $a->{game}->{home_team} cmp $b->{game}->{home_team}
		}
		gather {
        	for my $league (@$fixtures) {
    			for my $game ($league->{games}->@*) {
    				take {
    					league => $league->{league},
    					game => $game,
    				}
    			}
    		}
    	}
	];
}

=begin comment
sub do_recent_draws {
	my ($self, $fixtures) = @_;
	my @temp = ();
	
	for my $league (@$fixtures) {
		for my $game ($league->{games}-> @*) {
			push @temp, {
				league => $league->{league},
				game => $game,
			}
		}
	}
	
	return [
		sort {
			$b->{game}->{draws} <=> $a->{game}->{draws}
			or $b->{game}->{home_draws} <=> $a->{game}->{home_draws}
			or $a->{game}->{home_team} cmp $b->{game}->{home_team}
		} @temp
	];
}
=end comment
=cut

=pod

=head1 NAME

Model.pm

=head1 SYNOPSIS

Used by predict.pl

=head1 DESCRIPTION

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
