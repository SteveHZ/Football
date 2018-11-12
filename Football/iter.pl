
use strict;
use warnings;

sub get_maxp_rows {
    my ($self, $team) = @_;
    my @formats = ( $self->{format}, $self->{blank_text_format2},
                    $self->{currency_format}, $self->{percent_format},
    );
    my @format_idx = qw(0 1 0 1 2 1 2 1 2 1 2 1 3);
    my $iter = make_iter (\@formats, \@format_idx);
#    my $count = 0;

    return [
        map {
            { $_ => $formats [ $iter->() ] }
#            { $_ => $formats [$format_idx [$count ++]] }
        } @$team
    ];
}

sub make_iter {
    my ($formats, $format_idx) = @_;
#    my @format_idx = qw(0 1 0 1 2 1 2 1 2 1 2 1 3);
    my $index = 0;
    return sub {
        return $formats [ $format_idx [$index++] ];
#            return $data[$index++];
    }
}
