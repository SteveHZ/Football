#   combine.pl 03-11/11/18

use strict;
use warnings;
use v5.10;

use Spreadsheet::Read qw(ReadData);
use lib 'C:/Mine/perl/Football';
use Football::Spreadsheets::Combine_View;
use Data::Dumper;

my $path = 'c:/mine/perl/Football/reports';

my @expect_files = (
    { name => 'UK Expect', file => "$path/goal_expect.xlsx" },
    { name => 'Euro Expect', file => "$path/Euro/goal_expect.xlsx" },
#   { name => 'Summer Expect', file => "$path/Summer/goal_expect.ods" },
);
my @maxp_files = (
    { name => 'UK Homes', file => "$path/max_profit_uk.xlsx", sheet => 4, },
    { name => 'UK Aways', file => "$path/max_profit_uk.xlsx", sheet => 5, },
    { name => 'Euro Homes', file => "$path/Euro/max_profit_euro.xlsx", sheet => 4, },
    { name => 'Euro Aways', file => "$path/Euro/max_profit_euro.xlsx", sheet => 5, },
#   { name => 'Summer Max', file => "$path/Summer/max_profit_summer.xlsx" },
);
my $out_file = "$path/combined.xlsx";
my $data = {};
#my $tick_col = 27; # column AB

read_goal_expects ($data);
read_maxp ($data);

sub read_goal_expects {
    my $data = shift;
    for my $in_file (@expect_files) {
        say "\nReading $in_file->{file}";
        my $book = Spreadsheet::Read->new ($in_file->{file});
        my $sheet = $book->sheet(1);
        my @rows = $sheet->rows ();

        my $name = $in_file->{name};
        my $row_count = 0;
        for my $row (@rows) {
            next if $row_count++ < 2;
            push @{ $data->{$name} }, $row;
#            push @{ $data->{$name} }, $row if @$row[$tick_col] # if col AB not undef
        }
        for my $row (@{ $data->{$name} } ) {
            map { $_ = '' unless $_ } @$row; # amend all undef cells to blank
        }
    }
}

sub read_maxp {
    my $data = shift;
    for my $in_file (@maxp_files) {
        say "\nReading $in_file->{file} - $in_file->{name}";
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

say "\nWriting $out_file ...";
my $view = Football::Spreadsheets::Combine_View->new ();
$view->do_goal_expect ($data, \@expect_files);
$view->do_maxp ($data, \@maxp_files);
