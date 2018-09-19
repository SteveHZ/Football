#	fixtures2.pl 19-20/05/18

use strict;
use warnings;

use Football::Fixtures_Globals qw( football_rename rugby_rename );

my @paths = (
	{
		in_file  => 'C:/Mine/perl/Football/data/Euro/scraped/fixtures_uk.csv',
		out_file => 'C:/Mine/perl/Football/data/fixtures.csv',
		func => \&Football::Fixtures_Globals::football_rename,
	},
	{
		in_file  => 'C:/Mine/perl/Football/data/Euro/scraped/fixtures_euro.csv',
		out_file => 'C:/Mine/perl/Football/data/Euro/fixtures.csv',
		func => \&Football::Fixtures_Globals::football_rename,
	},
	{
		in_file  => 'C:/Mine/perl/Football/data/Euro/scraped/fixtures_summer.csv',
		out_file => 'C:/Mine/perl/Football/data/Summer/fixtures.csv',
		func => \&Football::Fixtures_Globals::football_rename,
	},
#	{
#		in_file  => 'C:/Mine/perl/Football/data/Euro/scraped/fixtures_rugby.csv',
#		out_file => 'C:/Mine/perl/Football/data/Rugby/fixtures.csv',
#		func => \&Football::Fixtures_Globals::rugby_rename,
#	},
);

for my $path (@paths) {
	if (-e $path->{in_file}) {
		open my $fh_in, '<', $path->{in_file}  or die "Can't find $path->{in_file}";
		open my $fh_out, '>', $path->{out_file} or die "Can't open $path->{out_file} for writing";

		while (my $line = <$fh_in>) {
			chomp $line;
			my @data = split ',', $line;
			$data[2] = $path->{func}->( $data[2] );	# home team
			$data[3] = $path->{func}->( $data[3] );	# away team

			print $fh_out $data[0].','.$data[1].','.$data[2].','.$data[3]."\n";
		}
		close $fh_in;
		close $fh_out;
		print "\nFinished writing $path->{out_file}";
	}
}

=pod

=head1 NAME

fixtures2.pl

=head1 SYNOPSIS

perl fixtures.pl

=head1 DESCRIPTION

 Run fixtures to write out 'fixtures_week.csv' then edit as required
 Run fixtures2.pl to write out finished 'fixtures.csv' file

=head1 AUTHOR

Steve Hope 2018

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
