package Football::BenchTest::Over_Under_Model;

use Football::Over_Under_Model;
use Moo;
use namespace::clean;

extends 'Football::Over_Under_Model';

sub BUILD {
    print "\nIn Over Under Benchtest model";
}

1;
