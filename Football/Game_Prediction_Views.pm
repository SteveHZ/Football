package Football::Game_Prediction_Views;

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

sub DEMOLISH {
	my $self = shift;
	$self->destroy_sheets ();
}

sub create_sheets {
	my $self = shift;

	$self->{xlsx_goal_expect} = Football::Spreadsheets::Goal_Expect_View->new ();
	$self->{xlsx_goal_diffs} = Football::Spreadsheets::Goal_Diffs_View->new ();
	$self->{xlsx_match_odds} = Football::Spreadsheets::Match_Odds_View->new ();
	$self->{xlsx_over_under} = Football::Spreadsheets::Over_Under_View->new ();
	$self->{xlsx_skellam} = Football::Spreadsheets::Skellam_Dist_View->new ();
}

sub destroy_sheets {
	my $self = shift;

	$self->{xlsx_goal_expect}->{workbook}->close ();
	$self->{xlsx_goal_diffs}->{workbook}->close ();
	$self->{xlsx_match_odds}->{workbook}->close ();
	$self->{xlsx_over_under}->{workbook}->close ();
	$self->{xlsx_skellam}->{workbook}->close ();
}

sub do_predict_models {
	my ($self, $leagues, $teams, $sorted) = @_;

	$self->do_goal_expect ($leagues, $teams, $sorted);
	$self->do_match_odds ($sorted);
	$self->do_over_under ($sorted);
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

1;
