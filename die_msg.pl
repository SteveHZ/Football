
use strict;
use warnings;

my $team = 'Stoke City';

print $team;
#    my $home_die_msg =  qq (\n\n
#        *** ZERO HOME GAMES for $team
#        *** Enable ZEROGAMES keyword in predict.pl and add '$team' to @remove_teams in fixtures2.pl
#    );
#my $home_die_msg = <<END;
#\n\n*** ZERO HOME GAMES for $team
#*** Enable ZEROGAMES keyword in predict.pl and add '$team' to @remove_teams in fixtures2.pl
#END

my $end_die_msg = "\nEnable ZEROGAMES keyword in predict.pl and add '$team' to remove_teams array in fixtures2.pl\n";
my $home_die_msg = "\n\n***ZERO HOME GAMES for $team".$end_die_msg;
my $away_die_msg = "\n\n***ZERO AWAY GAMES for $team".$end_die_msg;

print $home_die_msg;
print $away_die_msg;
