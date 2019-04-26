package Football::Game_Predictions::UK;

use Football::Spreadsheets::Goal_Expect_View;
use Football::Spreadsheets::Goal_Diffs_View;
use Football::Spreadsheets::Match_Odds_View;
use Football::Spreadsheets::Over_Under_View;
use Football::Spreadsheets::Skellam_Dist_View;

use Moo;
use namespace::clean;

sub BUILD {
	my $self = shift;
	$self->create_sheets ();
}

sub create_sheets {
	my $self = shift;

#print "\nBuilding sheets in UK !!";<STDIN>;
	$self->{xlsx_goal_expect} = Football::Spreadsheets::Goal_Expect_View->new ();
	$self->{xlsx_goal_diffs} = Football::Spreadsheets::Goal_Diffs_View->new ();
	$self->{xlsx_match_odds} = Football::Spreadsheets::Match_Odds_View->new ();
	$self->{xlsx_over_under} = Football::Spreadsheets::Over_Under_View->new ();
	$self->{xlsx_skellam} = Football::Spreadsheets::Skellam_Dist_View->new ();
}

sub do_goal_expect {
	my ($self, $leagues, $teams, $sorted) = @_;

	$self->{xlsx_goal_expect}->view ($leagues, $teams, $sorted->{expect});
	$self->{xlsx_goal_diffs}->view ($sorted);
}

sub do_match_odds {
	my ($self, $sorted) = @_;

	$self->{xlsx_skellam}->view ($sorted->{skellam});
	$self->{xlsx_match_odds}->view ($sorted->{match_odds});
}

sub do_over_under {
	my ($self, $sorted) = @_;
	$self->{xlsx_over_under}->view ($sorted->{over_under});
}

=pod

=head1 NAME

Football::Game_Predictions::UK.pm

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
