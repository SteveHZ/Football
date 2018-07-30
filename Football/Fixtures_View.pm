package Football::Fixtures_View;

use Data::Dumper;
use Moo;
use namespace::clean;

sub write_csv {
	my ($self, $filename, $games) = @_;
	
	print "\nWriting $filename...";
	open my $fh, '>', $filename or die "Can't open $filename";
	for my $game (@$games) {
		next if $game =~ /<LEAGUE>/; 	# for fixtures.pl
		next if $game =~ /,X,/;
		next if $game =~ /<DATE>/;
		print $fh $game."\n";
	}
	close $fh;
}

sub dump {
	my ($self, $games) = @_;
	print Dumper $games;
}

=pod

=head1 NAME

Fixtures_View.pm

=head1 SYNOPSIS

Used by fixtures.pl

=head1 DESCRIPTION

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;