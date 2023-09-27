use Test2::V0;
plan 1;

use Football::Value::Value_Model;
my $model = Football::Value::Value_Model->new ();

subtest 'calc_double_chance' => sub {
    my $dc = $model->calc_double_chance (2.02, 5.52);
    is ($model->calc_double_chance (2.02, 5.52), 1.48, "double chance odds ok");
};
