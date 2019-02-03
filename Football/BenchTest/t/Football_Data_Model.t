#   Football::BenchTest::Football_Data_Model.t 03/02/19

use strict;
use warnings;
use Test::More tests => 1;

use Football::BenchTest::Football_Data_Model;

my $data_model = Football::BenchTest::Football_Data_Model->new (path => 'C:/Mine/perl/Football/data/benchtest/test data');

subtest 'get_result' => sub {
    plan tests => 1;
    my $result = $data_model->get_result ('E1','Sheffield United','Swansea');
    is ($result, 'A', 'get_result ok');
}
