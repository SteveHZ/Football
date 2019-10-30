REM run football scripts 15/10/18

cd c:/mine/perl/football

perl fetch.pl
REM perl fetch_summer.pl

REM perl oddsp.pl ni welsh
REM perl oddsp.pl ni
REM perl oddsp.pl welsh

perl csvcat.pl ni ni
perl csvcat.pl wl welsh

perl predict.pl -u
perl predict.pl -eu
REM perl predict.pl -su

perl max_profit.pl
perl max_profit.pl -e
REM perl max_profit.pl -s

perl form.pl
perl combine.pl
perl backtest.pl