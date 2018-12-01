use strict;
use warnings;
use Data::Dumper;

my $array = [qw(prem champ lg1 scots)];
my $hash = get_idx ($array);
print Dumper $hash;

sub get_idx {
    my $array = shift;
    my $idx = 0;
#    my $hash = {};
#    for my $league (@$array) {
#
#        $hash->{$league} = $idx++;
#    }
    return {map { $_ => $idx++} @$array};
#return $hash;
}
