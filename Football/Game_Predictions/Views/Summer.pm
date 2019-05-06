package Football::Game_Predictions::Views::Summer;

use Summer::Spreadsheets::Goal_Expect_View;
use Summer::Spreadsheets::Goal_Diffs_View;
use Summer::Spreadsheets::Match_Odds_View;
use Summer::Spreadsheets::Over_Under_View;
use Summer::Spreadsheets::Skellam_Dist_View;

use Moo;
use namespace::clean;

extends 'Football::Game_Predictions::Views::UK';

sub create_sheets {
	my $self = shift;

	$self->{xlsx_goal_expect} = Summer::Spreadsheets::Goal_Expect_View->new ();
	$self->{xlsx_goal_diffs} = Summer::Spreadsheets::Goal_Diffs_View->new ();
	$self->{xlsx_match_odds} = Summer::Spreadsheets::Match_Odds_View->new ();
	$self->{xlsx_over_under} = Summer::Spreadsheets::Over_Under_View->new ();
	$self->{xlsx_skellam} = Summer::Spreadsheets::Skellam_Dist_View->new ();
}

=pod

=head1 NAME

Football::Game_Predictions::Summer.pm

=head1 SYNOPSIS

View for Game_Prediction triad

=head1 DESCRIPTION

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
