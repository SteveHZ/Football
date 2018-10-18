REM run football scripts 15/10/18

cd c:/mine/perl/football

perl fetch.pl
perl fetch_summer.pl
oddsp

perl predict.pl -u
perl predict.pl -eu
perl predict.pl -su

perl max_profit.pl
perl max_profit.pl -e
perl max_profit.pl -s
