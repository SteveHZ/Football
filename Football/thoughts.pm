Football::Max_Profit

Football Data Model needs amending somehow for different years
to run historical.pl (backtests) and probably create_reports for next years
(probably wouldnt even run now)

instead of throwing away first line
use indexes to find header columns - poss in a role ??

List::More Utils
indexes BLOCK LIST

Evaluates BLOCK for each element in LIST (assigned to $_) and returns a list of the indices of those elements for which BLOCK returned a true value. This is just like grep only that it returns indices instead of values:

@x = indexes { $_ % 2 == 0 } (1..10);   # returns 1, 3, 5, 7, 9
==
my @headers = qw(date hometeam aay team result fthg ftag)
read first line
@ line = split at comma
my @cols = indexes {$line eq $_ } @headers

get rid of self.my cols
mycols=find_cols self.headers
could also benchmark against other index funcs in moreutils
