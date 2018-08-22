package Rugby::Fixtures_Model;

use Football::Fixtures_Globals qw(%rugby_fixtures_leagues);
use Football::Fixtures_Scraper_Model;
use Rugby::Globals qw($season);
use MyRegX;
use MyDate qw( $month_names );
use Data::Dumper;

use utf8;
use Moo;
use namespace::clean;

my $str = join '|', keys %rugby_fixtures_leagues;
my $leagues = qr/$str/;

#my $rx = MyRegX->new ();

sub BUILD {
	my $self = shift;
	$self->{scraper} = Football::Fixtures_Scraper_Model->new ();
}

sub get_pages {
	my ($self, $sites) = @_;
	$self->{scraper}->get_rugby_pages ($sites);
}

sub prepare {
	my ($self, $dataref) = @_;
	my $team = $rx->team;
	my $time = $rx->time;
	my $date_parser = $rx->date_parser;

#	Remove beginning and end of data
	$$dataref =~ s/^.*Betfred//;
	$$dataref =~ s/Please.*$//g;
	$$dataref =~ s/\n//g;
	$$dataref =~ s/($leagues)/\n<LEAGUE>$1/g;

	$$dataref =~ s/($date_parser)(\s+)/\n<DATE>$1\n/g;
	$$dataref =~ s/($team+?)\s+($time)\s+($team+?)\s{2,}/$2-$1,$3\n/g;	

	my @lines = split '\n', $$dataref;
	shift @lines;
	return \@lines;
}

sub after_prepare {
	my ($self, $lines) = @_;
	my $date_parser = $rx->date_parser;
	my $csv_league = '';
	my $date = '';
	
	for my $line (@$lines) {
		if ($line =~ /^<LEAGUE>(.*)$/) {
			my $temp = $1;
			$temp =~ s/\s+$//; # remove end whitespace
			$csv_league = (exists $rugby_fixtures_leagues{$temp} ) ?
				$rugby_fixtures_leagues{$temp} : 'X';
		} elsif ($line =~ /^<DATE>$date_parser/) {
			$date = do_dates (\%+);
		} else {
			my ($time, $teams) = split '-', $line;
			$line =~ s/.*/$date $time,$csv_league,$teams/;
#			$line =~ s/(.*)/$date$csv_league,$date $1/;
		}
	}
	return $lines;
}

sub do_dates {
	my $hash = shift;

	my $dt = sprintf "%02d", $hash->{date};
	my $month = $month_names->{ $hash->{month} };
	return "$dt/$month";
}

sub delete_all {
	my ($self, $path, $week) = @_;
	for my $day (@$week) {
		unlink "$path/fixtures $day->{date}.txt"
	}
}

=pod

=head1 NAME

Rugby::Fixtures_Model.pm

=head1 SYNOPSIS

Used by fixtures.pl

=head1 DESCRIPTION

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
