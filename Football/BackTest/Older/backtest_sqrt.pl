
#   backtest_sqrt.pl 23-28/03/19

use strict;
use warnings;

use Football::Globals qw(@league_names @csv_leagues);
use Football::BenchTest::Adapter::Game_Prediction_Models;
use Football::BenchTest::Season;
use Football::BenchTest::FileList;
use Football::BenchTest::Goal_Expect_Model;
use Football::BenchTest::Goal_Diffs_Model;
use Football::BenchTest::Over_Under_Model;
use Football::BenchTest::OU_Points_Model;
use Football::BenchTest::Goal_Expect_Override;
use Football::BenchTest::Spreadsheets::BenchTest_View;

my $filename = 'C:/Mine/perl/Football/reports/backtest_sqrt.xlsx';
my $models = [
    Football::BenchTest::Goal_Expect_Model->new (),
    Football::BenchTest::Goal_Diffs_Model->new (),
    Football::BenchTest::Over_Under_Model->new (),
    Football::BenchTest::OU_Points_Model->new (),
];

my $file_list = Football::BenchTest::FileList->new (
    leagues     => \@league_names,
    csv_leagues => \@csv_leagues,
);
my $files = $file_list->get_current ();

my $season = Football::BenchTest::Season->new (
    models      => $models,
    files       => $files,
    callback    => \&do_predict_models,
);
$season->run ();

my $bt_view = Football::BenchTest::Spreadsheets::BenchTest_View->new (
    models      => $models,
    filename    => $filename,
);
$bt_view->write ();

sub do_predict_models {
	my ($self, $game, $league) = @_;
    my $predict_model = Football::BenchTest::Adapter::Game_Prediction_Models->new (
        game    => $game,
        league  => $league,
        models  => {
           'expect_model' =>   Football::BenchTest::Goal_Expect_Override->new (),
       },
    );

	my ($teams, $sorted) = $predict_model->calc_goal_expect ();
    $sorted->{over_under} = $predict_model->calc_over_under ();

    return $predict_model->get_data ($sorted);
}

=pod

=head1 NAME

Football/backtest_sqrt.pl

=head1 SYNOPSIS

perl backtest.pl

=head1 DESCRIPTION

Stand-alone script to backtest full season data with chosen models

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
