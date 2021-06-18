#   perl archive_csv.pl 21/05/19

#   Archive all csv sheets by copying from football/data directory
#   to football/data/historical/$league name directory
#   before running create_reports.pl

#   Ensure that $reports_season is updated in Football::Globals first !!! ($season -> NEXT season)
#   then run perl fetch.pl -n to fetch original csv sheets
#   Run perl amend_historical.pl afterwards, before perl create_reports.

use MyHeader;

use File::Copy qw(copy);
use List::MoreUtils qw(each_array);
use Football::Globals qw(@league_names @csv_leagues @euro_lgs @euro_csv_lgs $reports_season);

my $from_path = 'C:/Mine/perl/Football/data';
my $to_path = "$from_path/historical";

my $iterator = each_array (@csv_leagues, @league_names);
copy_files ($iterator);
say "\n";

$from_path = 'c:/mine/perl/football/data/Euro';
$to_path = "$from_path/Football data files";

$iterator = each_array (@euro_csv_lgs, @euro_lgs);
copy_files ($iterator);
say "\nDone";

sub copy_files ($iterator) {
    while (my ($csv, $league) = $iterator->()) {
        say "Copying $from_path/$csv.csv to $to_path/$league/$reports_season.csv";
        copy ("$from_path/$csv.csv", "$to_path/$league/$reports_season.csv");
    }
}

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
