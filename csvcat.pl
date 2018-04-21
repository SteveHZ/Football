
#	csvcat.pl 14/03/18

use strict;
use warnings;

die "Usage perl csvcat.pl to_file from_file(s)..." unless @ARGV >= 2;

my $to_file = "C:/Mine/perl/Football/data/Euro/$ARGV[0].csv";

for my $file_count (1..$#ARGV) {
	my $from_file = "C:/Mine/perl/Football/data/Euro/cleaned/$ARGV[ $file_count ].csv";

	print "\nReading $from_file..";
	open my $fh, '<', $from_file or die "Can't find $from_file !!";
	my $junk = <$fh>;
	chomp ( my @games = <$fh> );
	close $fh;

	print "\nAppending to $to_file..\n";
	open my $fh2, '>>', $to_file or die "Can't open $to_file !!";
	for my $game (@games) {
		chomp $game;
		my @line = split ',', $game;
		print $fh2 	$line[0].",".$line[1].",".$line[2],",". $line[3].",",
					$line[4].",". $line[5].",".$line[6].",,,,,,,,,,,,,,,,".
					$line[22].",". $line[23].",". $line[24].",0,0\n";
	}
	close $fh2;
}

=pod

=head1 NAME

csvcat.pl

=head1 SYNOPSIS

perl csvcat.pl to_file from_file(s)

=head1 DESCRIPTION

 Append from_file(s).csv to to_file.csv
 Do not use file extensions as part of argument
 
=head1 AUTHOR

Steve Hope 2018

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut