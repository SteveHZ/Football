
#   recent_draws.pl 07/05/19
#   Model::recent draws is much faster than either
#   recent_draws2 or recent_draws3

use strict;
use warnings;

use NestedMap;
use Football::Model;
use Test::More tests => 2;
use Test::Deep;
use Data::Dumper;
use Benchmark qw(:all);

my $model = Football::Model->new;
my $data = $model->quick_build ();
my $draws = $model->do_recent_draws ($data->{by_league});
my $draws2 = do_recent_draws2 ($data->{by_league});
my $draws3 = do_recent_draws3 ($data->{by_league});

#print Dumper $draws3;
cmp_deeply ($draws2, $draws,'$draws2 ok');
cmp_deeply ($draws3, $draws,'$draws3 ok');
do_benchmarks ();

sub do_recent_draws3 {
	my $fixtures = shift;

    push my @temp,
        nestedmap {
            nestedmap {
                [ $NestedMap::stack[0], $_ ]
            } @{$_->{games}}
        } @$fixtures;

    return [
		sort {
			$b->{game}->{draws} <=> $a->{game}->{draws}
			or $b->{game}->{home_draws} <=> $a->{game}->{home_draws}
			or $a->{game}->{home_team} cmp $b->{game}->{home_team}
		} map { {
            league => $_->[0]->{league},
            game => $_->[1],
        } }
        @temp
	];
}

sub do_recent_draws2 {
	my $fixtures = shift;

    my @temp = ();
    for my $league (@$fixtures) {
        push @temp, [ $league, $_ ] for @{ $league->{games}};
    }

    return [
		sort {
			$b->{game}->{draws} <=> $a->{game}->{draws}
			or $b->{game}->{home_draws} <=> $a->{game}->{home_draws}
			or $a->{game}->{home_team} cmp $b->{game}->{home_team}
		} map { {
            league => $_->[0]->{league},
            game => $_->[1],
        } }
        @temp
	];
}

sub do_benchmarks {
    my $t = timethese ( -10, {
        'old' => sub {
            my $sorted = $model->do_recent_draws ($data->{by_league});
            return $sorted;
        },
        'new2' => sub {
            my $sorted = do_recent_draws2 ($data->{by_league});
            return $sorted;
        },
        'new3' => sub {
            my $sorted = do_recent_draws3 ($data->{by_league});
            return $sorted;
        },
    });

    cmpthese $t;
}

=head
sub do_recent_draws {
	my ($self, $fixtures) = @_;

	my @temp = ();
	for my $league (@$fixtures) {
		for my $game (@{ $league->{games} } ) {
			push (@temp, {
				league => $league->{league},
				game => $game,
			});
		}
	}

	return [
		sort {
			$b->{game}->{draws} <=> $a->{game}->{draws}
			or $b->{game}->{home_draws} <=> $a->{game}->{home_draws}
			or $a->{game}->{home_team} cmp $b->{game}->{home_team}
		} @temp
	];
}
=cut
