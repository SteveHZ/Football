#   combine.pl 03-12/11/18, 15/12/18

use MyHeader;

use Spreadsheet::Read qw(ReadData);
use lib 'C:/Mine/perl/Football';
use Football::Spreadsheets::Combine_View;
use MyJSON qw (read_json);

my $path = 'c:/mine/perl/Football/data/combine data';

my $expect_files = [
    { name => 'UK Expect', file => "$path/expect UK.json" },
    { name => 'Euro Expect', file => "$path/expect Euro.json" },
    { name => 'Summer Expect', file => "$path/expect Summer.json" },
];

my $maxp_files = [
    { name => 'UK', file => "$path/maxp uk.json", },
#    { name => 'Euro', file => "$path/maxp euro.json", },
    { name => 'Summer', file => "$path/maxp summer.json", },
];

my $out_file = "$path/combined.xlsx";
my $data = {};

read_expects ($expect_files, $data);
read_maxp ($maxp_files, $data);

say "\nWriting $out_file ...";
my $view = Football::Spreadsheets::Combine_View->new ();

$view->do_goal_expect ($data, $expect_files);
$view->do_maxp ($data, $maxp_files);

sub read_expects {
    my ($files, $data) = @_;
    print "\n";
    for my $in_file (@$files) {
        my ($file, $name) = ( $in_file->{file}, $in_file->{name} );
        say "Reading $file - $name";
        my $games = read_json ($file);

        for my $game (@$games) {
            push $data->{$name}->@*, $game;
        }
    }
}

sub read_maxp {
    my ($files, $data) = @_;
    print "\n";
    my @keys = qw(homes aways);

    for my $in_file (@$files) {
        my ($file, $name) = ( $in_file->{file}, $in_file->{name}, );
        say "Reading $file - $name";
        my $teams = read_json ($file);

        for my $key (@keys) {
            my $sheetname = $name.' '.ucfirst $key;
            for my $team ( $teams->{$key}->@* ) {
                push $data->{$sheetname}->@*, $team;
            }
        }
    }
}
