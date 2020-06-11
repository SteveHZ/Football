use strict;
use warnings;

sub sort_by_data {
    return sort {
        $b->{key} <=> $a->{key}
    };
}

sub do_sort_by_keys {
    my ($self, $key) = @_;

    return sort {
        $b->{$key} <=> $a->{key}
    };
}

