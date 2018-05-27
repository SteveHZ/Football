package Football::Fixtures_View;

use Data::Dumper;
use Moo;
use namespace::clean;

sub write_csv {
	my ($self, $filename, $games) = @_;
	
	print "\nWriting $filename...";
	open my $fh, ">", $filename or die "Can't open $filename";
	for my $game (@$games) {
		next if $game =~ /^<LEAGUE>/;
		next if $game =~ /,X,/;
		print $fh $game."\n";
	}
	close $fh;
}

sub dump {
	my ($self, $games) = @_;
	print Dumper @$games;
}

1;