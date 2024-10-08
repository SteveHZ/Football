# move.pl 18/10/22

use strict;
use warnings;

use File::Copy;
use Football::Globals qw($reports_folder $cloud_folder $season);

my @files = (
	{ src => "$reports_folder/Match Odds UK.xlsx", dest => "$cloud_folder/Match Odds UK.xlsx" },
	{ src => "$reports_folder/Recent Match Odds UK.xlsx", dest => "$cloud_folder/Recent Match Odds UK.xlsx" },
	{ src => "$reports_folder/Match Odds Euro.xlsx", dest => "$cloud_folder/Euro/Match Odds Euro.xlsx" },
	{ src => "$reports_folder/Recent Match Odds Euro.xlsx", dest => "$cloud_folder/Euro/Recent Match Odds Euro.xlsx" },
	{ src => "$reports_folder/Match Odds Summer.xlsx", dest => "$cloud_folder/Summer/Match Odds Summer.xlsx" },
	{ src => "$reports_folder/Recent Match Odds Summer.xlsx", dest => "$cloud_folder/Summer/Recent Match Odds Summer.xlsx" },
	{ src => "$reports_folder/value.xlsx", dest => "$cloud_folder/value.xlsx" },
	{ src => "$reports_folder/halftime_fulltime.xlsx", dest => "$cloud_folder/halftime_fulltime.xlsx" },
	{ src => "$reports_folder/fantasy.xlsx", dest => "$cloud_folder/fantasy.xlsx" },

	{ src => "$reports_folder/returns UK.xlsx", dest => "$cloud_folder/returns UK.xlsx" },
	{ src => "$reports_folder/streaks UK.xlsx", dest => "$cloud_folder/streaks UK.xlsx" },
	{ src => "$reports_folder/series s1 UK.xlsx", dest => "$cloud_folder/series s1 UK.xlsx" },
	{ src => "$reports_folder/series s246 UK.xlsx", dest => "$cloud_folder/series s246 UK.xlsx" },
	{ src => "$reports_folder/series s369 UK.xlsx", dest => "$cloud_folder/series s369 UK.xlsx" },
	{ src => "$reports_folder/series stoffo UK.xlsx", dest => "$cloud_folder/series stoffo UK.xlsx" },

	{ src => "$reports_folder/returns Euro.xlsx", dest => "$cloud_folder/Euro/returns Euro.xlsx" },
	{ src => "$reports_folder/streaks Euro.xlsx", dest => "$cloud_folder/Euro/streaks Euro.xlsx" },
	{ src => "$reports_folder/series s1 Euro.xlsx", dest => "$cloud_folder/Euro/series s1 Euro.xlsx" },
	{ src => "$reports_folder/series s246 Euro.xlsx", dest => "$cloud_folder/Euro/series s246 Euro.xlsx" },
	{ src => "$reports_folder/series s369 Euro.xlsx", dest => "$cloud_folder/Euro/series s369 Euro.xlsx" },
	{ src => "$reports_folder/series stoffo Euro.xlsx", dest => "$cloud_folder/Euro/series stoffo Euro.xlsx" },

	{ src => "$reports_folder/returns Summer.xlsx", dest => "$cloud_folder/Summer/returns Summer.xlsx" },
	{ src => "$reports_folder/streaks Summer.xlsx", dest => "$cloud_folder/Summer/streaks Summer.xlsx" },
	{ src => "$reports_folder/series s1 Summer.xlsx", dest => "$cloud_folder/Summer/series s1 Summer.xlsx" },
	{ src => "$reports_folder/series s246 Summer.xlsx", dest => "$cloud_folder/Summer/series s246 Summer.xlsx" },
	{ src => "$reports_folder/series s369 Summer.xlsx", dest => "$cloud_folder/Summer/series s369 Summer.xlsx" },
	{ src => "$reports_folder/series stoffo Summer.xlsx", dest => "$cloud_folder/Summer/series stoffo Summer.xlsx" },

	{ src => 'C:/Mine/My Dime List.csv', dest => 'C:/Users/Steve/OneDrive/Documents/My Dime List.csv' },
);

for my $file (@files) {
	print "\nCopying $file->{src} to $file->{dest}";
	copy $file->{src}, $file->{dest};
}

=pod

=head1 NAME

move.pl

=head1 SYNOPSIS

perl move.pl

=head1 DESCRIPTION

Copy all football report files to my One Drive folder

=head1 AUTHOR

Steve Hope 2022

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
