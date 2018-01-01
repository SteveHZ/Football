package Football::Over_Under_Model;

#	Football::Over_Under_Model.pm 21/12/17

use Moo;
use namespace::clean;

has 'fixtures' => (is => 'ro');

sub do_home_away {
	my $self = shift;

	return [
		sort {
			$b->{home_away} <=> $a->{home_away}
			or $b->{last_six} <=> $a->{last_six}
			or $a->{home_team} cmp $b->{home_team}
		} @{ $self->{fixtures} }
	];
}

sub do_last_six {
	my $self = shift;

	return [ 
		sort {
			$b->{last_six} <=> $a->{last_six}
			or $b->{home_away} <=> $a->{home_away}
			or $a->{home_team} cmp $b->{home_team}
		} @{ $self->{fixtures} }
	];
}

sub do_over_under {
	my $self = shift;

	return [
		sort {
#			$a->{over_2pt5} <=> $b->{over_2pt5}
			$b->{under_2pt5} <=> $a->{under_2pt5}
			or $a->{home_team} cmp $b->{home_team}
		} @{ $self->{fixtures} }
	];
}

=pod

=head1 NAME

Over_Under_Model.pm

=head1 SYNOPSIS

Used by predict.pl
Called from Game_Prediction_Models package

=head1 DESCRIPTION

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
