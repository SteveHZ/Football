#	fixtures.pl 05-14/05/18
#	v1.1 29/07-12/08/18, v1.2 20-22/09/18
#   v1.3 08-14/10/19, v1.4 03/11/19

BEGIN { $ENV{PERL_KEYWORD_PRODUCTION} = 1;}
BEGIN { $ENV{PERL_KEYWORD_TESTING} = 0; }
BEGIN { $ENV{PERL_KEYWORD_DELETEALL} = 1;}

use strict;
use warnings;
use Getopt::Long qw(GetOptions);
#use utf8;

use MyKeyword qw(PRODUCTION DELETEALL);
use Football::Fixtures::Model;
use Football::Fixtures::View;

my $path = 'C:/Mine/perl/Football/data/Euro/scraped';
my $site = 'https://www.bbc.co.uk/sport/football/scores-fixtures';

do_football ();

sub do_football {
	my $model = Football::Fixtures::Model->new ();
	my $view = Football::Fixtures::View->new ();

	my $args = get_cmdline ();
	my $week = $model->get_week ($args);
	my $all_games = {};

	PRODUCTION {
		$model->get_pages ($site, $week);
	}

	for my $day (@$week) {
		my $filename = "$path/fixtures $day->{date}.txt";
        my $games = $model->read_file ($filename, $day);

		for my $key (keys %$games) {
			push $all_games->{$key}->@*, $_ for $games->{$key}->@*;
		}
	}

    $view->dump ($all_games);
	my $fname = "$path/fixtures_week";
	$view->write_csv ($fname, $all_games);

	DELETEALL {
		$model->delete_all ($path, $week);
	}
}

sub get_cmdline {
    my $days = 7;
	my $today = 0;

	Getopt::Long::Configure ("bundling");
	GetOptions (
        "days|d=i"=> \$days,
		"today|t=i" => \$today,
	) or die "\nUsage : perl fixtures.pl -d7 -t1 \n[d = days t = today ]\nt1 will include today, default is 0\n";

	return {
		days => $days,
		include_today => $today,
	};
}

=pod

=head1 NAME

 fixtures.pl

=head1 SYNOPSIS

 perl fixtures.pl -d7 -t0
 Default options : days 7 today 0 (do NOT include todays fixtures),
 Use -today 1 to include todays fixtures
 To download 3 days INCLUDING today, use -d2 -t1
 
=head1 DESCRIPTION

 Scrapes BBC Sport website for future fixtures
 Writes out to a file called 'fixtures_week.csv' which can be edited as required
 Run fixtures2.pl to write out finished 'fixtures.csv' file(s)

=head1 AUTHOR

 Steve Hope 2018

=head1 LICENSE

 This library is free software. You can redistribute it and/or modify
 it under the same terms as Perl itself.

=cut
