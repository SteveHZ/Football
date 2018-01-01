package Football::Form_Model2;

use Football::Spreadsheets::Form2;
use Moo;
use namespace::clean;

has 'leagues' => ( is => 'ro' );
has 'all_teams' => (is => 'ro' );
has 'sorted' => (is => 'ro' );

sub BUILD {
	my $self = shift;
	$self->{all_teams} = $self->create_list ();

	$self->{form}->{sort_all} = $self->sort_list ('all');
	$self->{form}->{sort_home} = $self->sort_list ('home');
	$self->{form}->{sort_away} = $self->sort_list ('away');
	$self->{form}->{sort_last_six} = $self->sort_list ('last_six');
}

sub create_list {
	my $self = shift;
	my @list = ();

	for my $league (@{ $self->{leagues} }) {
		for my $team (@{ $league->team_list} ) {
			push (@list, {
				league => $league->{title},
				team => $team,
				all => \% {$league->get_table ()->{$team} },
				home => \% { $league->{homes}->{$team} },
				away => \% { $league->{aways}->{$team} },
				last_six => \% { $league->{last_six}->{$team} },
			});
		}
	}
	return \@list;
}

sub sort_list {
	my ($self, $sort_by) = @_;

	my @list = sort {
		$b->{$sort_by}->{points} <=> $a->{$sort_by}->{points}
		or $a->{team} cmp $b->{team}
	} @{ $self->{all_teams} };

	return \@list;
}

sub show {
	my $self = shift;

	my $form_view = Football::Spreadsheets::Form2->new ();
	$form_view->show ( $self->{form} );
	print "\nDone";
}

#	for my $team (@{ $self->{form}->{sort_all} } ) {
#		print "\n$team->{league} - $team->{team}";
#		print " - $team->{all}->{points}";
#		print " - $team->{home}->{points}";
#		print " - $team->{away}->{points}";
#		print " - $team->{last_six}->{points}";
##		print " home gd = $team->{all}->goal_difference ($team->{name})"; 
#	}
##	<STDIN>;
#	for my $team (@{ $self->{form}->{sort_home} } ) {
#		print "\n$team->{league} - $team->{team}";
#		print " - $team->{all}->{points}";
#		print " - $team->{home}->{points}";
#		print " - $team->{away}->{points}";
#		print " - $team->{last_six}->{points}";
#		print " home gd = $team->{home}->{goal_difference}"; 
#	}
##	<STDIN>;
#	for my $team (@{ $self->{form}->{sort_away} } ) {
#		print "\n$team->{league} - $team->{team}";
#		print " - $team->{all}->{points}";
#		print " - $team->{home}->{points}";
#		print " - $team->{away}->{points}";
#		print " - $team->{last_six}->{points}";
#		print " away gd = $team->{away}->{goal_difference}"; 
#	}
##	<STDIN>;
#	for my $team (@{ $self->{form}->{sort_last_six} } ) {
#		print "\n$team->{league} - $team->{team}";
#		print " - $team->{all}->{points}";
#		print " - $team->{home}->{points}";
#		print " - $team->{away}->{points}";
#		print " - $team->{last_six}->{points}";
#		print " last six gd = $team->{last_six}->{goal_difference}"; 
#	}

1;