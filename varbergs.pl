use MyHeader;
use MyLib qw(read_file);
use Football::Fetch_Amend;
use Football::Globals qw(@summer_csv_leagues);

my $lines = read_file "C:/Mine/perl/Football/data/Summer/SWE.csv";
chomp $_ for @$lines;

for my $line (@$lines) {
	$line =~ s/Varberg,/Varbergs,/g;
}
#print Dumper $lines;

my $amend = Football::Fetch_Amend->new;
my $hash = $amend->get_summer_hash ();

print Dumper $hash;
print Dumper @summer_csv_leagues;

for my $league (@summer_csv_leagues) {
	print "\n ** exists : $league **" if exists $hash->{$league};
}
