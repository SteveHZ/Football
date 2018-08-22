#	fixtures.pl 05-14/05/18
#	v1.1 29/07-12/08/18

#BEGIN { $ENV{PERL_KEYWORD_PRODUCTION} = 1;}
#BEGIN { $ENV{PERL_KEYWORD_DELETEALL} = 1;}
BEGIN { $ENV{PERL_KEYWORD_FOOTBALL} = 1;}
#BEGIN { $ENV{PERL_KEYWORD_RUGBY} = 1;}

use strict;
use warnings;

use Football::Fixtures_Model;
use Football::Fixtures_View;
use Rugby::Fixtures_Model;
use Rugby::Globals qw(@league_names);
use MyKeyword qw(PRODUCTION DELETEALL FOOTBALL RUGBY);
use Data::Dumper;

my $data = get_data ();
my $view = Football::Fixtures_View->new ();
my $path = "C:/Mine/perl/Football/data/Euro/scraped";

FOOTBALL { do_football (); }
RUGBY 	 { do_rugby (); }

sub do_football {
	my $model = Football::Fixtures_Model->new ();
	my $week = $model->get_week ();
	my @all_games = ();
	PRODUCTION {
		$model->get_pages ($data->{football}->{sites}, $week);
	}

	for my $day (@$week) {
		my $filename = "$path/fixtures $day->{date}.txt";
		open my $fh, '<', $filename or die "Can't open $filename";
		chomp ( my $data = <$fh> );
		close $fh;

		my $date = $model->as_date_month ($day->{date});
		my $games = $model->after_prepare (
			$model->prepare (\$data, $day->{day}, $date)
		);

		push @all_games, @$games;
		$view->dump ($games);
	}

	my $out_file = "$path/fixtures_week.csv";
	$view->write_csv ($out_file, \@all_games);

	DELETEALL {
		$model->delete_all ($path, $week);
	}
}

sub do_rugby {
	my $model = Rugby::Fixtures_Model->new ();
	my @all_games = ();
	PRODUCTION {
		$model->get_pages ($data->{rugby}->{sites});
	}
	
	for my $league (@league_names) {
		my $filename = "$path/$league.txt";

		open my $fh, '<', $filename or die "Can't open $filename";
		chomp ( my $data = <$fh> );
		close $fh;

		my $games = $model->after_prepare (
			$model->prepare (\$data)
		);

		push @all_games, @$games;
		$view->dump ($games);
	}

	my $out_file = "$path/fixtures_rugby.csv";
	$view->write_csv ($out_file, \@all_games);

#	DELETEALL {
#		$model->delete_all ($path, $week);
#	}
}

sub get_data {
	return {
		football => {
			sites => [
				"https://www.bbc.co.uk/sport/football/scores-fixtures",
			], 
		},
		rugby => {
			sites => [
				"https://www.bbc.co.uk/sport/rugby-league/super-league/fixtures",
				"https://www.bbc.co.uk/sport/rugby-league/championship/fixtures",
				"https://www.bbc.co.uk/sport/rugby-league/league-one/fixtures",
			],
		},
	};
}

=pod

=head1 NAME

fixtures.pl

=head1 SYNOPSIS

perl fixtures.pl

=head1 DESCRIPTION

 Scrapes BBC Sport website for future fixtures
 Writes out to a file called 'fixtures_week.csv' which can be edited as required
 Run fixtures2.pl to write out finished 'fixtures.csv' file
 
=head1 AUTHOR

Steve Hope 2018

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut