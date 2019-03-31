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

=pod

=head1 NAME

Football/BenchTest/Roles/ModelBase.pm

=head1 SYNOPSIS

used by BenchTest Models as base

=head1 DESCRIPTION

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
