#   shots.pl 27/02/20

use strict;
use warnings;

use Football::Football_Data_Model;
use Football::Utils qw(_get_all_teams);
use Text::Table;
#use Math::CDF;
#use Data::Dumper;

my $data_model = Football::Football_Data_Model->new (
    'my_keys' => [ qw(date home_team away_team home_score away_score result home_shots away_shots) ],
);

my $games = $data_model->read_csv ('C:/Mine/perl/Football/data/E0.csv');
my $teams = _get_all_teams ($games,'home_team');

my $totals = {};
$totals->{home_goals} = 0;
$totals->{away_goals} = 0;

my $data = {};
my @data_keys = ( qw(home_shots home_goals away_shots away_goals) );
for my $team (@$teams) {
    $data->{$team}->{$_} = 0 for @data_keys;
}

for my $game (@$games) {
    $data->{$game->{home_team}}->{home_shots} += $game->{home_shots};
    $data->{$game->{home_team}}->{home_goals} += $game->{home_score};
    $totals->{home_goals} += $game->{home_score};

    $data->{$game->{away_team}}->{away_shots} += $game->{away_shots};
    $data->{$game->{away_team}}->{away_goals} += $game->{away_score};
    $totals->{away_goals} += $game->{away_score};
}

my $table = Text::Table->new ('Team','Home Shots','Home Goals','Home Ratio','Away Shots','Away Goals','Away Ratio');
for my $team (@$teams) {
    my $home_ratio = _format ($data->{$team}->{home_goals} / $data->{$team}->{home_shots});
    my $away_ratio = _format ($data->{$team}->{away_goals} / $data->{$team}->{away_shots});

    $table->add ($team, $data->{$team}->{home_shots}, $data->{$team}->{home_goals}, $home_ratio,
                        $data->{$team}->{away_shots}, $data->{$team}->{away_goals}, $away_ratio
    );
}
print $table;

print "\n".binomial ($data->{Liverpool}->{home_shots}, $data->{Liverpool}->{home_goals});
print "\n".binomial2 ($data->{Liverpool}->{home_shots}, $data->{Liverpool}->{home_goals});

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
