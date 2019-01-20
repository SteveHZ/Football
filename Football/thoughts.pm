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
