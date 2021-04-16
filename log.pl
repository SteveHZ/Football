# log.pl 13/03/21

# https://metacpan.org/pod/Log::Log4perl
# https://perlmaven.com/logging-with-log4perl-the-easy-way
# https://perlmaven.com/some-refactoring-and-add-logging-to-mail-boxer
# https://www.perl.com/pub/2002/09/11/log4perl.html/

#use Log::Log4perl qw(:easy);
#Log::Log4perl->easy_init($ERROR);
##ERROR "test";
#my $log = get_logger ('football');
#my $year = 2021;
#$log->error ("testing $year ok");

use Log::Log4perl;
Log::Log4perl->init ("log.conf");
my $year = 2021;
my $log = Log::Log4perl->get_logger ('football');
$log->error ("testing $year ok");

# https://perlmaven.com/use-theschwartz-2
# my $log_file = "/var/tmp/send_email_worker.log";
# open(LOG,">>$log_file") or die "Can not open $log_file!";
# print LOG "sendmail: $sendmail\n";

my $log_file = "C:/Mine/perl/Football/football2.log";
open my $log, '>>', $log_file or die "Can't open $log_file";

my $next_year = 2022;
print $log "testing $next_year ok\n";
$next_year ++;
print $log "testing $next_year ok\n";

close $log;