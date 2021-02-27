package Football::Fetch_Amend;

use MyLib qw(read_file write_file);
use File::Copy qw(copy);

use Moo;
use namespace::clean;

sub get_hash {
	return {
		'E0' => [
			sub { $_[0] =~ s/Man United/Man Utd/g },
			sub { $_[0] =~ s/Sheffield United/Sheff Utd/g },
		],
		'E1' => [
			sub { $_[0] =~ s/Sheffield Weds/Sheff Wed/g },
			sub { $_[0] =~ s/Nott'm Forest/Notts Forest/g },
		],
		'E2' => [
			sub { $_[0] =~ s/Mil.*Dons/MK Dons/g },
		],
		'EC' => [
			sub { $_[0] =~ s/Kin.*nn/Kings Lynn/g },
		],
	};
}

sub amend_teams {
	my ($self, $replace, $path) = @_;
	$path //= "C:/Mine/perl/Football/data";

	while (my ($league, $teams_rx) = each $replace->%*) {
		my $file = "$path/$league.csv";
		my $temp_file = "$path/$league-temp.csv";

		print "\nRewriting $file...";
		copy $file, $temp_file;
		my $lines = read_file ($temp_file);
		for my $replace_rx (@$teams_rx) {
			$replace_rx->($_) for @$lines;
		}

		write_file ($file, $lines);
		unlink $temp_file;
	}
}

1;