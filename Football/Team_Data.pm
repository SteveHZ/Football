package Team_Data;

use Mu;
use namespace::clean

ro 'name', default => '';
ro 'points', default => 0;
ro 'draws', default => 0;
ro 'goal_difference', default => 0;

ro 'homes', default => sub { [] };
ro 'full_homes' default => sub { [] };
ro 'home_over_under' default => 0;

ro 'aways' default => sub { [] };
ro 'full_aways' default => sub { [] };
ro 'away_over_under' default => 0;

ro 'last_six' default => sub { [] };
ro 'full_last_six' default => sub { [] };
ro 'last_six_for' default => 0;
ro 'last_six_against' default => 0;
ro 'last_six_over_under' default => 0;

sub BUILD {}

1;
