#   data_clean_favs.pl 06-07/10/18

use strict;
use warnings;
use v5.010; # say

use MyJSON qw(write_json read_json);
use MyLib qw(is_empty_array);
use Football::Globals qw($season);
use File::Copy qw(move);

my $path = 'C:/Mine/perl/Football/data';
my $filename = "$path/favourites_history.json";
my $backup = "$path/favourites_history_back.json";

my @cleaned = ();
my $idx;

my $data = read_json ($filename);

for my $week (@$data) {
    if (is_empty_array (\@cleaned)) {
        push @cleaned, @$data[0];
        $idx = 0;
    } else {
        if (is_different ($week, $cleaned[$idx])) {
            push @cleaned, $week;
            $idx ++;
        }
    }
}

move ($filename, $backup);
say "Writing $filename...";
write_json ($filename, \@cleaned);

my $data_lines = scalar @$data;
my $cleaned_lines = scalar @cleaned;
say "Edited $data_lines lines to $cleaned_lines.";
say "Done.";

sub is_different {
    my ($week, $cleaned) = @_;

    for my $league (keys %$week) {
        my $weekref = $week->{$league}->{$season};
        my $cleanedref = $cleaned->{$league}->{$season};

        for my $key (keys %$weekref) {
            return 1 if $weekref->{$key} != $cleanedref->{$key};
        }
    }
    return 0;
}
