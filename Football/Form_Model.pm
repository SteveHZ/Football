package Football::Form_Model;

use Football::Spreadsheets::Form_View;
use Moo;
use namespace::clean;

has 'leagues' => ( is => 'ro' );
has 'filename' => ( is => 'ro' );

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
				league => $league->{name},
				team => $team,
				all => $league->get_table->{$team},
				home => $league->get_team_home_data ($team),
				away => $league->get_team_away_data ($team),
				last_six => $league->get_team_last_six_data ($team),
			});
		}
	}
	return \@list;
}

sub sort_list {
	my ($self, $sort_by) = @_;

	return [
		sort {
			$b->{$sort_by}->{points} <=> $a->{$sort_by}->{points}
			or $a->{team} cmp $b->{team}
		} @{ $self->{all_teams} }
	];
}

sub show {
	my $self = shift;

	my $form_view = Football::Spreadsheets::Form_View->new ( filename => $self->{filename} );
	$form_view->show ( $self->{form} );
	print "\nDone\n";
}

=pod

=head1 NAME

Form_Model.pm

=head1 SYNOPSIS

Used by form.pl

=head1 DESCRIPTION

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
