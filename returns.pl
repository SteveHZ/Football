# returns.pl 07/01/21 v1.1 13/01/21

use MyHeader;
use MyLib qw (read_file);
use Football::Globals qw($dropbox_folder);
use Football::Spreadsheets::Write_Returns;
use Football::Spreadsheets::Write_Streaks;

my $returns_rx = qr/
    \w{2,3}\,           # League ID
    [\w\h]+\,           # Team
    \d+,                # Stake
    .*?\d+\.?\d+?,      # Return
    \d+\.?\d+?          # Percentage Return
/x;

my $country;
if (! defined $ARGV[0]) {
	$country = "UK";
} else {
	$country = "Summer" if $ARGV[0] eq '-s';
	$country = "Euro" if $ARGV[0] eq '-e';
}

my $returns_filename = "$dropbox_folder/returns $country.xlsx";
my $streaks_filename = "$dropbox_folder/streaks $country.xlsx";

my @files = (
    {
        in_file => "C:/Mine/lisp/data/returns $country.csv",
        out_file => $returns_filename,
        writer => Football::Spreadsheets::Write_Returns->new (filename => $returns_filename),
    },
#    {
#        in_file => "C:/Mine/lisp/data/streaks $country.csv",
#        out_file => $streaks_filename,
#        writer => Football::Spreadsheets::Write_Streaks->new (filename => $streaks_filename),
#    },
);

sub build_hash {
    my $lines = shift;
    my $hash = {};
    my $key = "";

    for my $line (@$lines) {
    	chomp $line;
    	if ($line !~ $returns_rx) {
    		$key = $line unless $line eq "";
    	} else {
    		push $hash->{$key}->@*, $line;
    	}
    }
    return $hash;
}

for my $file (@files) {
    my $lines = read_file ($file->{in_file});
    my $hash = build_hash ($lines);

    print "\nWriting $file->{out_file}...";
    $file->{writer}->write ($hash);

    print "Done";
}
