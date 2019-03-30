package Football::BenchTest::Adapter::Game_Prediction_Models;

use List::Util qw(any);
use Moo;
use namespace::clean;

extends 'Football::Game_Prediction_Models';
has 'game' => (is => 'ro', required => 1);
has 'league' => (is => 'ro', required => 1);

sub BUILD {
    my $self = shift;
    $self->{fixtures}    = [ $self->{game} ];
    $self->{leagues}     = [ $self->{league} ];

    my @expects_args = qw( expect_model over_under_model );
	for my $name (keys %{$self->{models}} ) {
        if (any { $_ eq $name} @expects_args) {
       		$self->{models}->{$name}->{fixtures} = $self->{fixtures};
    		$self->{models}->{$name}->{leagues} = $self->{leagues};
        }
    }
}

1;
