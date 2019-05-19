#   combine.pl 03-12/11/18, 15/12/18

use strict;
use warnings;
use v5.10;

use Spreadsheet::Read qw(ReadData);
use lib 'C:/Mine/perl/Football';
use Football::Spreadsheets::Combine_View;

my $path = 'c:/mine/perl/Football/reports';

my $expect_files = [
    { name => 'UK Expect', file => "$path/goal_expect.xlsx", sheet => 1, },
    { name => 'Euro Expect', file => "$path/Euro/goal_expect.xlsx", sheet => 1, },
    { name => 'Summer Expect', file => "$path/Summer/goal_expect.xlsx", sheet => 1 },
];

my $maxp_files = [
    { name => 'UK Homes', file => "$path/max_profit.xlsx", sheet => 4, },
    { name => 'UK Aways', file => "$path/max_profit.xlsx", sheet => 5, },
    { name => 'Euro Homes', file => "$path/Euro/max_profit.xlsx", sheet => 4, },
    { name => 'Euro Aways', file => "$path/Euro/max_profit.xlsx", sheet => 5, },
    { name => 'Summer Homes', file => "$path/Summer/max_profit.xlsx", sheet => 4, },
    { name => 'Summer Aways', file => "$path/Summer/max_profit.xlsx", sheet => 5, },
];

my $out_file = "$path/combined.xlsx";
my $data = {};

read_files ($expect_files, $data);
read_files ($maxp_files, $data);

say "\nWriting $out_file ...";
my $view = Football::Spreadsheets::Combine_View->new ();

# hopfully sorted
# This always clobbers UK expect because max profit spreadsheet
# module will always create a new sheet and euro is set to 0 as default
# as a work-around, need a better way !!

# Might have to $self->create_sheet for UK,Euro,Summer and for combine view (blank_file.xlsx)??
# NEXT IDEA - to write out as HTML using Template Toolkit ??
# OR to write out CSV from GE Model and MXP Model using TT
# then read back in here instead of using Spreadsheet Read ??
# would not keep formats but could maybe be worked around in HTML ??

$view->do_goal_expect ($data, $expect_files);
$view->do_maxp ($data, $maxp_files);

sub read_files {
    my ($files, $data) = @_;
    print "\n";
    for my $in_file (@$files) {
        say "Reading $in_file->{file} - $in_file->{name}";
        my $book = Spreadsheet::Read->new ($in_file->{file});
        my $sheet = $book->sheet($in_file->{sheet});
        my @rows = $sheet->rows ();

        my $name = $in_file->{name};
        my $row_count = 0;
        for my $row (@rows) {
            next if $row_count++ < 2;
            push @{ $data->{$name} }, $row;
        }
        for my $row (@{ $data->{$name} } ) {
            map { $_ = '' unless $_ } @$row; # amend all undef cells to blank
        }
    }
}
