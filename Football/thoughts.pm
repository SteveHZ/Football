Shared Model :

sub build_data {
$model_data = {}
model_data->{games}=read_games
model_data->{leagues}=build_leagues # do these two need to be in hash?
model_data->{homes}=get_homes
model_data->{aways} =get_aways .. fetch
return $model_data
}

$data=model->build_data
$expect =model->do_goal_expect
-

build_data
/    model.t
/    MyBessel_bench
Goal_Expect
/    home_table away_table
/    assigned in shared model, should have accessor in team_data ??

Should Shared_Model build_date do home_table do_away_table be in League::build_leagies ??
over under cache ?
Should Over Under Model ou_points be in league
or all over under stuff be in a role used by league ?? (<- prob not)

Game prediction models shold take leagues and fixtures as argumentd
do $game->ou_calc inGame Preds for $gamr{do_calcs} then call do ove under pts return [sort{}]
