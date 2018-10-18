package Football::Results_View;

use Football::Fixtures_Globals qw(football_rename);
use Data::Dumper;
use Moo;
use namespace::clean;

sub write_csv {
	my ($self, $path, $league, $games) = @_;

	my $filename = "$path/$league.csv";
	print "\nWriting $filename...";
	open my $fh, '>', $filename or die "Can't open $filename";
	print $fh "Date,Home Team,Away Team,H,A\n";

	for my $month (@$games) {
		for my $game (@$month) {
			my @data = split ',', $game;
			$data[1] = football_rename ($data[1]);	# home team
			$data[2] = football_rename ($data[2]);	# away team
			print $fh $data[0].','.$data[1].','.$data[2].','.$data[3].','.$data[4]."\n";
		}
	}
	close $fh;
}

sub dump {
	my ($self, $games) = @_;
	print Dumper %$games;
}

=pod

=head1 NAME

Results_View.pm

=head1 SYNOPSIS

Used by results.pl

=head1 DESCRIPTION

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
