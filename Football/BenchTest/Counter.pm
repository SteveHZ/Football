package Football::BenchTest::Counter;

use Moo;
use namespace::clean;

has 'model' => (is => 'ro');

sub BUILD {
    my $self = shift;
    for my $key (@{ $self->model->keys } ) {
        for my $i (@{ $self->model->range } ) {
            $self->{$key}->{$i} = { wins => 0, from => 0, };
        }
    }
}

sub do_counts {
    my ($self, $data) = @_;

    for my $n (@{ $self->model->range } ) {
        for my $key (@{ $self->model->keys } ) {
            $self->{$key}->{$n}->{wins} ++ if $self->model->do_wins ($key, $data, $n);
            $self->{$key}->{$n}->{from} ++ if $self->model->do_from ($key, $data, $n);
        }
    }
}

sub get_data {
    my ($self, $key, $n) = @_;
    return ( $self->{$key}->{$n}->{wins}, $self->{$key}->{$n}->{from} );
}

sub get_data_wins {
    my ($self, $key, $n) = @_;
    return $self->{$key}->{$n}->{wins};
}

sub get_data_from {
    my ($self, $key, $n) = @_;
    return $self->{$key}->{$n}->{from};
}

1;
