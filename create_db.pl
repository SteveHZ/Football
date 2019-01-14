
#   create_db.pl 10/01/19
#   No point in creating a massive db for all leagues
#   as different files have different number of columns !!

use strict;
use warnings;
use v5.10;

use Football::Globals qw(@csv_leagues);

my $path = "C:/Mine/perl/Football/data";
open my $out_fh, '>', "$path/db.csv" or die "Can't open db.csv";
print $out_fh "Div,Date,HomeTeam,AwayTeam,FTHG,FTAG,FTR,HTHG,HTAG,HTR,Referee,HS,AS,HST,AST,HF,AF,HC,AC,HY,AY,HR,AR,B365H,B365D,B365A,BWH,BWD,BWA,IWH,IWD,IWA,PSH,PSD,PSA,WHH,WHD,WHA,VCH,VCD,VCA,Bb1X2,BbMxH,BbAvH,BbMxD,BbAvD,BbMxA,BbAvA,BbOU,BbMx>2.5,BbAv>2.5,BbMx<2.5,BbAv<2.5,BbAH,BbAHh,BbMxAHH,BbAvAHH,BbMxAHA,BbAvAHA,PSCH,PSCD,PSCA,SortDate\n";

for my $league (@csv_leagues) {
    say "Reading $league.csv";
    open my $in_fh, '<', "$path/$league.csv" or die "Can't open $league.csv";
    my $line = <$in_fh>;
    while ($line = <$in_fh>) {
        chomp ($line);
        my @csv = split ',', $line;
        my $sort_date = get_date ($csv[1]);
        print $out_fh "$line,$sort_date\n";
    }
    close $in_fh;
}
close $out_fh;

sub get_date {
	my $date = shift;
    return "$3$2$1" if $date =~ m!(\d{2})/(\d{2})/(\d{4})!;
    return 0;
}
