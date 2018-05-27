package Football::Roles::Fetch_Goal_Diff;

use Moo::Role;

sub fetch_goal_difference {
	my ($self, $goal_diff_obj, $league_name, $goal_difference) = @_;
	return $goal_diff_obj->fetch_array ("Premier League", $goal_difference);
}

=pod

=head1 NAME

Fetch_Goal_Diff.pm

=head1 SYNOPSIS

Used by predict.pl

=head1 DESCRIPTION

Override the fetch_goal_difference class in Football::Model
for child classes Euro::Model and Summer::Model

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;