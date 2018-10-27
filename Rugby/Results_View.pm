package Rugby::Results_View;

use Football::Fixtures_Globals qw(rugby_rename);
use Data::Dumper;
use Moo;
use namespace::clean;

sub write_csv {
	my ($self, $path, $games) = @_;

	for my $league (keys %$games) {
		my $filename = "$path/$league.csv";
		print "\nWriting $filename...";

		open my $fh, '>', $filename or die "Can't open $filename";
		print $fh "Date,Home Team,Away Team,H,A\n";
		for my $game (@ { $games->{$league} } ) {
			next if $game =~ /<DATE>/;
			next if $game =~ /,X,/;

			my @data = split ',', $game;
			$data[1] = rugby_rename ($data[1]);
			$data[2] = rugby_rename ($data[2]);
			print $fh $data[0].','.$data[1].','.$data[2].','.$data[3].','.$data[4]."\n";
		}
		close $fh;

	}
}

sub dump {
	my ($self, $games) = @_;
	print Dumper @$games;
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
