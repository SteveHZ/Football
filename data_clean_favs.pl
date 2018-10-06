
#   data_clean_favs.pl 06/10/18

use strict;
use warnings;
use v5.010; # say

use MyJSON qw(write_json read_json);
use Football::Globals qw($season);
use File::Copy qw(move);

my $path = 'C:/Mine/perl/Football/data';
my $filename = "$path/favourites_history.json";
my $backup = "$path/favourites_history_back.json";

my @cleaned = ();
my $idx;

my $data = read_json ($filename);

for my $week (@$data) {
    if (is_empty (\@cleaned)) {
        push @cleaned, @$data[0];
        $idx = 0;
    } else {
        if (compare ($cleaned[$idx], $week)) {
            push @cleaned, $week;
            $idx ++;
        }
    }
}

move ($filename, $backup);
say "Writing $filename...";
write_json ($filename, \@cleaned);
say "Done";

sub is_empty {
    my $arrayref = shift;
    return $#$arrayref == -1;
}

sub compare {
    my ($cleaned, $week) = @_;

    for my $league (keys %$week) {
        my $weekref = $week->{$league}->{$season};
        my $cleanref = $cleaned->{$league}->{$season};

        for my $key (keys %$weekref) {
            return 1 if $weekref->{$key} != $cleanref->{$key};
        }
    }
    return 0;
}
