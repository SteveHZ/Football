package Rugby::Fixtures_Model;

use Football::Fixtures_Globals qw(%rugby_fixtures_leagues);
use Football::Fixtures_Scraper_Model;
use Rugby::Globals qw($season);
use MyRegX;
use MyDate qw( $month_names );
use Data::Dumper;

use Time::Piece qw(localtime);
use Time::Seconds qw(ONE_DAY);

use utf8;
use Moo;
use namespace::clean;

my $str = join '|', keys %rugby_fixtures_leagues;
my $leagues = qr/$str/;

my $rx = MyRegX->new ();

sub BUILD {
	my $self = shift;
	$self->{scraper} = Football::Fixtures_Scraper_Model->new ();
}

sub get_pages {
	my ($self, $sites, $week) = @_;
	for my $site (@$sites) {
		$self->{scraper}->get_rugby_pages ($site, $week);
	}
}

sub prepare {
	my ($self, $dataref, $day, $date) = @_;
	return [] unless $$dataref =~ /[Betfred|Australian]/;

	my $team = $rx->team;
	my $time = $rx->time;
	my $lower = $rx->lower;
	my $upper = $rx->upper;
	my $date_parser = $rx->date_parser;

#	Remove beginning and end of data
	$$dataref =~ s/^.*Content//;
	$$dataref =~ s/All times are UK.*$//g;
	$self->data_clean ($dataref);

	$$dataref =~ s/($leagues)/\n<LEAGUE>$1/g;
	$$dataref =~ s/($lower)($upper)/$1\n$2/g; # find where team names meet
	$$dataref =~ s/($team+?)($time)($team+?)/$day-$date-$2-$1-$3/g;

	my @lines = split '\n', $$dataref;
	shift @lines;
	return \@lines;
}

sub data_clean {
	my ($self, $dataref) = @_;
	$$dataref =~ s/League 1/League One/g;
	$$dataref =~ s/ [A-Z]+C//g; # remove RLFC,ARLFC etc (ARL,SARLC,RLC in Conference leagues)
	$$dataref =~ s/ XIII//g; # Toulouse
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
			my ($day, $date, $time, $home, $away) = split '-', $line;
			$line =~ s/.*/$day $date $time,$csv_league,$home,$away/;
		}
	}
#	print Dumper $lines;<STDIN>;
	return $lines;
}

sub as_date_month {
	my ($self, $date) = @_;
	return $rx->as_date_month ($date);
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
		unlink "$path/rugby $day->{date}.txt"
	}
}

sub get_week {
	my ($self, $days, $forwards) = @_;
	$days //= 10;
	$forwards //= 1;

	my @week = ();
	my $today = localtime;

#	for my $day_count (0..$days) {
	for my $day_count (1..$days) {
		my $day = ($forwards) ?
			$today + ($day_count * ONE_DAY):
			$today - ($day_count * ONE_DAY);
		push @week, {
			day	 => substr ($day->wdayname, 0, 2),
			date => $day->ymd,
		};
	}
	return \@week;
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
