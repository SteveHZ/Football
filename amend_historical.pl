# amend_historical.pl 08-10/03/21

# copy original historical data to to 'Football Data files' folder
# then use this script to amend team names as per Football::Fetch_Amend

use strict;
use warnings;
use Time::HiRes qw (usleep);

use Football::Fetch_Amend;
use MyLib qw(read_file write_file);
use Football::Globals qw( @league_names @league_size $reports_seasons);

sub transform_hoa_to_array {
	my $hash = shift;
	my @rx_array = ();

	for my $league (keys $hash->%*) {
		for my $team_rx ($hash->{$league}->@*) {
			push @rx_array, $team_rx;
		}
	}
	return \@rx_array;
}

my $amend = Football::Fetch_Amend->new ();
my $rx_hash = $amend->get_uk_hash ();
my $rx_array = transform_hoa_to_array ($rx_hash);

for my $league (@league_names) {
	mkdir "C:/Mine/perl/Football/data/historical/$league"
		unless -d "C:/Mine/perl/Football/data/historical/$league";
	my $in_path = "C:/Mine/perl/Football/data/Football data files/$league";
	my $out_path = "C:/Mine/perl/Football/data/historical/$league";

	for my $season ($reports_seasons->{$league}->@*) {
		my $in_file = "$in_path/$season.csv";
		my $out_file = "$out_path/$season.csv";

		print "\nReading $in_file";
		my $lines = read_file ($in_file);
		$amend->amend_array ($lines, $rx_array);

		print "\nWriting $out_file";
		write_file ($out_file, $lines);
		usleep 500000; # 0.5 seconds, to avoid buffer problems
	}
}

=pod

=head1 NAME

 Football/amend_historical.pl

=head1 SYNOPSIS

 perl amend_historical.pl

=head1 DESCRIPTION

 Stand-alone script to amend original historical data from Football data
 to data/historical folder using regex defined in Football::Fetch_Amend

 Always run this when regex has been updated, before running perl create_reports.pl

=head1 AUTHOR

 Steve Hope

=head1 LICENSE

 This library is free software. You can redistribute it and/or modify
 it under the same terms as Perl itself.

=cut

=begin comment

#sub amend_array {
#	my ($lines, $rx_array) = @_;
#	for my $line (@$lines) {
#		for my $rx ($rx_array->@*) {
#			$rx->($line);
#		}
#	}
#}

#my $last_season = $reports_season;
my $english = [ 1995..$reports_season ];
my $conference = [ 2005..$reports_season ];
my $scottish = [ 2000..$reports_season ];
my $fav_seasons = [ 2010..$reports_season ];

my $seasons = {
	'Premier League'	=> $english,
	'Championship'    	=> $english,
	'League One' 		=> $english,
	'League Two' 		=> $english,
	'Conference' 		=> $conference,
	'Scots Premier' 	=> $scottish,
	'Scots Championship'=> $scottish,
	'Scots League One' 	=> $scottish,
	'Scots League Two' 	=> $scottish,
};

=end comment
=cut
