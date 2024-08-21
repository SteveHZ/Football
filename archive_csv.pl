#   perl archive_csv.pl 21/05/19

#   Archive all csv sheets by copying from football/data directory
#   to football/data/historical/$league name directory
#   before running create_reports.pl

#   Run perl fetch.pl to fetch Football Data csv sheets
#	Next, ensure that $reports_season is updated in Football::Globals ($season -> NEXT season)
   
#	IGNORE THS PARAGRAPH !!
#	Run this script to write to Football Data Files folder,
#   then run perl amend_historical.pl afterwards, before perl create_reports.

# 	10/06/24
# 	Accidentally deleted old data files at some point, but do not need to rewrite historical data every time,
# 	only need to amend the most recent season, so no need to run amend_historical.pl. Amended script to write to correct folder.

use MyHeader;

use File::Copy qw(copy);
use List::MoreUtils qw(each_array);
use Football::Globals qw(@league_names @csv_leagues @euro_lgs @euro_csv_lgs $reports_season);

my $from_path = 'C:/Mine/perl/Football/data';
my $iterator = each_array (@csv_leagues, @league_names);

while (my ($csv, $league) = $iterator->()) {
	my $to_path = "C:/Mine/perl/Football/data/historical/$league";
	mkdir $to_path unless -d $to_path;

    say "Copying $from_path/$csv.csv to $to_path/$reports_season.csv";
	copy ("$from_path/$csv.csv", "$to_path/$reports_season.csv");
}

#copy_files ($iterator);

#sub copy_files ($iterator) {
#    while (my ($csv, $league) = $iterator->()) {
#		my $to_path = "C:/Mine/perl/Football/data/historical/$league";
#		mkdir $to_path unless -d $to_path;

#        say "Copying $from_path/$csv.csv to $to_path/$reports_season.csv";
#        copy ("$from_path/$csv.csv", "$to_path/$reports_season.csv");
#    }
#}

#$from_path = 'c:/mine/perl/Football/data/Euro';
#$to_path = "$from_path/Football data files";
#mkdir $to_path unless -d $to_path;

#$iterator = each_array (@euro_csv_lgs, @euro_lgs);
#copy_files ($iterator);
#say "\nDone";


=pod

=head1 NAME

archive_csv.pl

=head1 SYNOPSIS

perl archive_csv.pl

=head1 DESCRIPTION

Archive all csv sheets by copying from football/data directory
to football/data/historical/(league name) directory
before running create_reports.pl

Ensure that $reports_season is updated in Football::Globals first !!!
then run perl fetch.pl -n to fetch original csv sheets
Run perl amend_historical.pl afterwards, before perl create_reports.

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
