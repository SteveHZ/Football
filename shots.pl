#   shots.pl 27/02/20

use strict;
use warnings;

use Football::Football_Data_Model;
use Football::Utils qw(_get_all_teams);
use Text::Table;
use MyStats qw(binomial_coeff binomial_prob);
use Data::Dumper;

my $data_model = Football::Football_Data_Model->new (
    'my_keys' => [ qw(date home_team away_team home_score away_score result home_shots away_shots) ],
);

my $games = $data_model->read_csv ('C:/Mine/perl/Football/data/E0.csv');
my $teams = _get_all_teams ($games,'home_team');

my @data_keys = ( qw(home_shots home_goals away_shots away_goals) );
my $totals = {};
$totals->{$_} = 0 for @data_keys;

my $data = {};
for my $team (@$teams) {
    $data->{$team}->{$_} = 0 for @data_keys;
}

for my $game (@$games) {
    $data->{$game->{home_team}}->{home_shots} += $game->{home_shots};
    $data->{$game->{home_team}}->{home_goals} += $game->{home_score};
    $totals->{home_shots} += $game->{home_shots};
    $totals->{home_goals} += $game->{home_score};

    $data->{$game->{away_team}}->{away_shots} += $game->{away_shots};
    $data->{$game->{away_team}}->{away_goals} += $game->{away_score};
    $totals->{away_shots} += $game->{away_shots};
    $totals->{away_goals} += $game->{away_score};
}

my $av_home_shots = $totals->{home_shots} / scalar @$teams;
my $av_away_shots = $totals->{away_shots} / scalar @$teams;

for my $team (@$teams) {
    $data->{$team}->{home_shots_ratio} = _format ($data->{$team}->{home_shots} / $av_home_shots);
    $data->{$team}->{away_shots_ratio} = _format ($data->{$team}->{away_shots} / $av_away_shots);
}

my $table = Text::Table->new ('Team','Home Shots','Home Goals','Home Ratio','Away Shots','Away Goals','Away Ratio','HShotsRatio','AShotsRatio');
for my $team (@$teams) {
    my $home_ratio = _format ($data->{$team}->{home_goals} / $data->{$team}->{home_shots});
    my $away_ratio = _format ($data->{$team}->{away_goals} / $data->{$team}->{away_shots});

    $table->add ($team, $data->{$team}->{home_shots}, $data->{$team}->{home_goals}, $home_ratio,
                        $data->{$team}->{away_shots}, $data->{$team}->{away_goals}, $away_ratio,
                        $data->{$team}->{home_shots_ratio}, $data->{$team}->{away_shots_ratio},
    );
}
print $table;

print "\nAverage Home Shots = $av_home_shots";
print "\nAverage Away Shots = $av_away_shots";
print "\nbinomial = ".binomial ($data->{Liverpool}->{home_shots}, $data->{Liverpool}->{home_goals});
print "\nbinomial2 = ".binomial2 ($data->{Liverpool}->{home_shots}, $data->{Liverpool}->{home_goals});
print "\nhome ratio = ".$data->{Liverpool}->{home_goals} / $data->{Liverpool}->{home_shots};
print "\nhome goals = ". $data->{Liverpool}->{home_goals};
print "\nhome shots ratio = ".$data->{Liverpool}->{home_shots_ratio};
#print "\nbinomial_prob = ",binomial_prob ($data->{Liverpool}->{home_goals} / $data->{Liverpool}->{home_shots}, $data->{Liverpool}->{home_goals},$data->{Liverpool}->{home_shots_ratio});

print "\n3 out of 5 = ".binomial_coeff (5,3);
print "\nLottery = ". binomial_coeff (49,6);
print "\nLottery = ". binomial_coeff (59,6);

sub _format {
    my $value = shift;
    return sprintf "%.2f", $value;
}

# from rosetta code site
sub binomial {
    my ($r, $n, $k) = (1, @_);
    for (1 .. $k) {
        $r *= $n--;
        $r /= $_
    }
    return _format $r;
}

sub binomial2 {
    use bigint; # only use locally
    my($n,$k) = @_;
#   print Dumper (0+$n); # bigint object
    return _format ((0+$n)->bnok($k));
}

=head
Perl

sub binomial2 {
    use bigint;
    my ($r, $n, $k) = (1, @_);
    for (1 .. $k) {
        $r *= $n--;
        $r /= $_
    }
    return $r;
}

print binomial(5, 3);

Output:

10

Since the bigint module already has a binomial method, this could also be written as:

sub binomial {
    use bigint;
    my($n,$k) = @_;
    (0+$n)->bnok($k);
}

For better performance, especially with large inputs, one can also use something like:
Library
: ntheory

use ntheory qw/binomial/;
print length(binomial(100000,50000)), "\n";

Output:

30101

The Math::Pari module also has binomial, but it needs large amounts of added stack space for large arguments (this is due to using a very old version of the underlying Pari library).
=cut
