# 	fixtures3.pl 07-08/12/23

use strict;
use warnings;

use MyLib qw(read_file);
use Football::Globals qw (@csv_leagues);

my $path = "C:/Mine/perl/Football/data";
my $lines = read_file ("$path/fixtures.csv");

my @sorted = ();
my @temp = ();

for my $line (@$lines) {
	push @temp, [ split ',', $line ];
}

for my $league (@csv_leagues) {
	my @lines = grep { $_->[1] eq $league } @temp;
	push @sorted, $_ for @lines;
}

print "\nWriting $path/fixtures3.csv...";
write_file ("$path/fixtures3.csv", \@sorted);
print "Done\n";

sub write_file {
	my ($filename, $lines) = @_;

	open my $fh, '>', $filename or die "Unable to open $filename";
	for my $line (@$lines) {
		print $fh "$line->[0],$line->[1],$line->[2],$line->[3]";
	}
	close $fh;
}

=pod

=head1 NAME

Football/fixtures3.pl

=head1 SYNOPSIS

perl fixtures3.pl

=head1 DESCRIPTION

Stand-alone script to sort fixtures.dat files into leagues to be copied and pastes into dnb.csv.

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

