#   Fixtures_Globals.t 20/10/18

use strict;
use warnings;

use Test::More tests => 1;
use Football::Fixtures_Globals qw(football_rename rugby_rename);

subtest 'rename' => sub {
    plan tests => 4;

    my $team = football_rename ('Stoke City');
    is ($team, 'Stoke', 'amended Stoke City to Stoke');
    $team = rugby_rename ('Stoke City');
    is ($team, 'Stoke City', 'not found Stoke City in Rugby');
    $team = rugby_rename ('Leigh');
    is ($team, 'Leigh Centurions', 'amended Leigh to Leigh Centurions');
    $team = football_rename ('Leigh');
    is ($team, 'Leigh', 'not found Leigh in Football');
};
