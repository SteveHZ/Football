# move.pl 18/10/22

use strict;
use warnings;

use File::Copy;
use Football::Globals qw($reports_folder $cloud_folder);

my @files = (
	{ src => "$reports_folder/Match Odds UK.xlsx", dest => "$cloud_folder/Match Odds UK.xlsx" },
	{ src => "$reports_folder/Recent Match Odds UK.xlsx", dest => "$cloud_folder/Recent Match Odds UK.xlsx" },
	{ src => "$reports_folder/Match Odds Euro.xlsx", dest => "$cloud_folder/Euro/Match Odds Euro.xlsx" },
	{ src => "$reports_folder/Recent Match Odds Euro.xlsx", dest => "$cloud_folder/Euro/Recent Match Odds Euro.xlsx" },
	{ src => "$reports_folder/Match Odds Summer.xlsx", dest => "$cloud_folder/Summer/Match Odds Summer.xlsx" },
	{ src => "$reports_folder/Recent Match Odds Summer.xlsx", dest => "$cloud_folder/Summer/Recent Match Odds Summer.xlsx" },
	{ src => "$reports_folder/fantasy.xlsx", dest => "$cloud_folder/fantasy.xlsx" },


	{ src => "$reports_folder/returns UK.xlsx", dest => "$cloud_folder/returns UK.xlsx" },
	{ src => "$reports_folder/streaks UK.xlsx", dest => "$cloud_folder/streaks UK.xlsx" },
	{ src => "$reports_folder/series s1 UK.xlsx", dest => "$cloud_folder/series s1 UK.xlsx" },
	{ src => "$reports_folder/series s2 UK.xlsx", dest => "$cloud_folder/series s2 UK.xlsx" },
	{ src => "$reports_folder/series s3 UK.xlsx", dest => "$cloud_folder/series s3 UK.xlsx" },
	{ src => "$reports_folder/series stoffo UK.xlsx", dest => "$cloud_folder/series stoffo UK.xlsx" },

	{ src => "$reports_folder/returns Euro.xlsx", dest => "$cloud_folder/Euro/returns Euro.xlsx" },
	{ src => "$reports_folder/streaks Euro.xlsx", dest => "$cloud_folder/Euro/streaks Euro.xlsx" },
	{ src => "$reports_folder/series s1 Euro.xlsx", dest => "$cloud_folder/Euro/series s1 Euro.xlsx" },
	{ src => "$reports_folder/series s2 Euro.xlsx", dest => "$cloud_folder/Euro/series s2 Euro.xlsx" },
	{ src => "$reports_folder/series s3 Euro.xlsx", dest => "$cloud_folder/Euro/series s3 Euro.xlsx" },
	{ src => "$reports_folder/series stoffo Euro.xlsx", dest => "$cloud_folder/Euro/series stoffo Euro.xlsx" },

	{ src => "$reports_folder/returns Summer.xlsx", dest => "$cloud_folder/Summer/returns Summer.xlsx" },
	{ src => "$reports_folder/streaks Summer.xlsx", dest => "$cloud_folder/Summer/streaks Summer.xlsx" },
	{ src => "$reports_folder/series s1 Summer.xlsx", dest => "$cloud_folder/Summer/series s1 Summer.xlsx" },
	{ src => "$reports_folder/series s2 Summer.xlsx", dest => "$cloud_folder/Summer/series s2 Summer.xlsx" },
	{ src => "$reports_folder/series s3 Summer.xlsx", dest => "$cloud_folder/Summer/series s3 Summer.xlsx" },
	{ src => "$reports_folder/series stoffo Summer.xlsx", dest => "$cloud_folder/Summer/series stoffo Summer.xlsx" },

	{ src => 'C:/Mine/My Dime List.csv', dest => 'C:/Users/Steve/OneDrive/Documents/My Dime List.csv' },

);

for my $file (@files) {
	print "\nCopying $file->{src} to $file->{dest}";
	copy $file->{src}, $file->{dest};
}

=begin comment

use Time::Piece qw(localtime);

my $copy = (! (-e $dest_file) ||
				check_date_modified ($src_file, $dest_file))
				? 1 : 0;

if ($copy) {
	print" ... copying to $dest_path/$file\n";
	copy "$source_dir/$file", "$dest_path/$file";
}

sub check_date_modified {
	my ($src_file, $dest_file) = @_;

	return (
		date_modified ($src_file)
		> date_modified ($dest_file)
	) ? 1 : 0;
}

sub date_modified {
	my $file = shift;

	my @stats = stat $file;
	my $lt = localtime $stats[9]; # Time::Piece::localtime
	return sprintf "%4d%02d%02d", $lt->year, $lt->mon, $lt->mday;
}
=end comment
=cut

=pod

=head1 NAME

backup_docs.pl

=head1 SYNOPSIS

perl backup_docs.pl

=head1 DESCRIPTION

Back up all document files

=head1 AUTHOR

Steve Hope 2015

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
