#	fixtures2.pl 19-20/05/18

use strict;
use warnings;

use List::Util qw(any);
use Football::Fixtures_Globals qw( football_rename rugby_rename );

my @remove_teams = (
#	"Montreal", # Home 14/04
	"Sandefjord", # Home 21/04
	"Tromso", # Away 21/04
	"EIF", # Home 21/04
	"Haka", # Away 20/04
	"Ilves", # Away 19/04
	"Lahti", # Home 20/04
 	"Mariehamn", # Away 20/04
	"Oulu", # Home 27/04
);
# Once array is empty, disable ZEROGAMES pragma in predict.pl

my @paths = (
	{
		in_file  => 'C:/Mine/perl/Football/data/Euro/scraped/fixtures_week_uk.csv',
		out_file => 'C:/Mine/perl/Football/data/fixtures.csv',
		func 	 => sub { football_rename (@_) },
	},
	{
		in_file  => 'C:/Mine/perl/Football/data/Euro/scraped/fixtures_week_euro.csv',
		out_file => 'C:/Mine/perl/Football/data/Euro/fixtures.csv',
		func	 => sub { football_rename (@_) },
	},
	{
		in_file  => 'C:/Mine/perl/Football/data/Euro/scraped/fixtures_week_summer.csv',
		out_file => 'C:/Mine/perl/Football/data/Summer/fixtures.csv',
		func  	 => sub { football_rename (@_) },
	},
#	{
#		in_file  => 'C:/Mine/perl/Football/data/Euro/scraped/fixtures_week_rugby.csv',
#		out_file => 'C:/Mine/perl/Football/data/Rugby/fixtures.csv',
#		func => sub { rugby_rename (@_) },
#	},
);

for my $path (@paths) {
	if (-e $path->{in_file}) {
		open my $fh_in,  '<', $path->{in_file}  or die "Can't find $path->{in_file} for reading";
		open my $fh_out, '>', $path->{out_file} or die "Can't open $path->{out_file} for writing";

		while (my $line = <$fh_in>) {
			chomp $line;
			my @data = split ',', $line;
			$data[2] = $path->{func}->( $data[2] );	# home team
			$data[3] = $path->{func}->( $data[3] );	# away team

			if (scalar (@remove_teams)) {
				next if any { $data[2] eq $_ } @remove_teams;
				next if any { $data[3] eq $_ } @remove_teams;
			}
			print $fh_out "$data[0],$data[1],$data[2],$data[3]\n";
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

perl fixtures2.pl

=head1 DESCRIPTION

 Run fixtures.pl to write out 'fixtures_week.csv' then remove unwanted fixtures as required.
 Run fixtures2.pl to write out finished 'fixtures.csv' file with amended team names.

=head1 AUTHOR

Steve Hope 2018

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
