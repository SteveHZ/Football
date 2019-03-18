package Football::Roles::Counter;

use Football::BenchTest::Counter;
use Moo::Role;

has 'counter' => (is => 'ro', handles => [ qw(do_counts) ]);
has 'dispatch' => (is => 'ro', builder => '_build_dispatch');
has 'keys' => (is =>'ro');
has 'headings' => ( is => 'ro');
has 'range' => (is =>'ro');
has 'sheetname' => (is => 'ro');
#has 'dispatch' => (is => 'ro');

requires qw(counter keys headings range sheetname _build_dispatch);

sub BUILD {}

after 'BUILD' => sub {
    my $self = shift;
    $self->{counter} = Football::BenchTest::Counter->new (model => $self);
};

sub do_wins {
    my ($self, $key, $data, $n) = @_;
    return $self->dispatch->{$key}->{wins}->($self, $data, $n);
}

sub do_from {
    my ($self, $key, $data, $n) = @_;
    return $self->dispatch->{$key}->{from}->($self, $data, $n);
}

1;
