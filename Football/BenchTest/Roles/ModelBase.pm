package Football::BenchTest::Roles::ModelBase;

use Football::BenchTest::Counter;
use Moo::Role;

has 'counter' => (is => 'ro', handles => [ qw( do_counts ) ]);
has 'dispatch' => (is => 'ro', builder => '_build_dispatch');
has 'keys' => (is =>'ro');
has 'headings' => ( is => 'ro');
has 'range' => (is =>'ro');
has 'sheetname' => (is => 'ro');

requires qw(_build_dispatch keys headings range sheetname);

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
