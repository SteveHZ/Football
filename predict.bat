REM run football scripts 15/10/18

cd c:/mine/perl/football

REM perl fetch.pl
perl fetch_summer.pl

REM ** oddsp.bat
REM perl oddsp.pl ni welsh
REM perl oddsp.pl ni
REM perl oddsp.pl welsh

REM perl csvcat.pl ni ni
REM perl csvcat.pl wl welsh

REM perl predict.pl -u
REM perl predict.pl -eu
perl predict.pl -su

REM perl max_profit.pl
REM perl max_profit.pl -e
perl max_profit.pl -s

perl combine.pl
REM perl combine.pl
REM perl form.pl

REM perl backtest.pl