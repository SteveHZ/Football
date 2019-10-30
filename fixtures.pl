#	fixtures_new.pl 05-14/05/18
#	v1.1 29/07-12/08/18
#	v1.2 20-22/09/18
#   v1.3 08-14/10/19

BEGIN { $ENV{PERL_KEYWORD_PRODUCTION} = 1;}
BEGIN { $ENV{PERL_KEYWORD_TESTING} = 0; }
BEGIN { $ENV{PERL_KEYWORD_DELETEALL} = 1;}

use strict;
use warnings;
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
	my $week = $model->get_week ();
	my $all_games = {};

	PRODUCTION {
		$model->get_pages ($site, $week);
	}

	for my $day (@$week) {
		my $filename = "$path/fixtures $day->{date}.txt";
        my $games = $model->read_file ($filename, $day);

		for my $key (keys %$games) {
			push @{ $all_games->{$key} }, $_ for (@{ $games->{$key} });
		}
	}

    $view->dump ($all_games);
	my $fname = "$path/fixtures_week";
	$view->write_csv ($fname, $all_games);

	DELETEALL {
		$model->delete_all ($path, $week);
	}
}

=pod

=head1 NAME

fixtures.pl

=head1 SYNOPSIS

perl fixtures.pl

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
