package Football::Fixtures_Model;

use Football::Fixtures_Globals qw(%football_fixtures_leagues);
use Football::Fixtures_Scraper_Model;
use MyRegX;

use Time::Piece qw(localtime);
use Time::Seconds qw(ONE_DAY);
use utf8;
use Moo;
use namespace::clean;

my $str = join '|', keys %football_fixtures_leagues;
my $leagues = qr/$str/;

my $rx = MyRegX->new ();
my $time = $rx->time;
my $upper = $rx->upper;
my $lower = $rx->lower;
my $dm_date = $rx->dm_date;

sub BUILD {
	my $self = shift;
	$self->{scraper} = Football::Fixtures_Scraper_Model->new ();
}

sub get_pages {
	my ($self, $site, $week) = @_;
	$self->{scraper}->get_pages ($site, $week);
}

sub prepare {
	my ($self, $dataref, $day, $date) = @_;

#	Remove beginning and end of data
	$$dataref =~ s/^.*Content//;
	$$dataref =~ s/All times are UK .*$//g;

#	Identify known leagues
	$$dataref =~ s/($leagues)/\n<LEAGUE>$1/g;

#	Work-arounds
	$self->do_initial_chars ($dataref);
	$self->do_foreign_chars ($dataref);

#	Find where team names start	
	$$dataref =~ s/($lower)($upper)/$1\n$day $date,$2/g;

#	Undo SOME workarounds
	$self->revert ($dataref);
	
	$$dataref =~ s/($time)/,$1,/g;

	my @lines = split '\n', $$dataref;
	shift @lines;
	return \@lines;
}

sub after_prepare {
	my ($self, $lines) = @_;
	my $csv_league = '';
	
	for my $line (@$lines) {
		if ($line =~ /^<LEAGUE>(.*)$/) {
			$csv_league = (exists $football_fixtures_leagues{$1} ) ?
				$football_fixtures_leagues{$1} : 'X';
		} else {
			$line =~ s/($dm_date),(.*),($time),(.*)/$1 $3,$csv_league,$2,$4/;
		}
	}
	return $lines;
}

sub delete_all {
	my ($self, $path, $week) = @_;
	for my $day (@$week) {
		unlink "$path/fixtures $day->{date}.txt"
	}
}

sub as_date_month {
	my ($self, $date) = @_;
	return $rx->as_date_month ($date);
}

#	no longer used but tests exist
sub as_dmy {
	my ($self, $date) = @_;
	return $rx->as_dmy ($date);
}

sub get_week {
	my ($self, $days, $forwards) = @_;
	$days //= 10;
	$forwards //= 1;
	
	my @week = ();
	my $today = localtime;
	
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

sub get_reverse_week {
	my ($self, $days) = @_;
	$days //= 10;
	$self->get_week ($days, 0);
}

sub do_foreign_chars {
	my ($self, $dataref) = @_;
	$$dataref =~ s/ä/a/g;
	$$dataref =~ s/å/a/g;
	$$dataref =~ s/ö/o/g;
	$$dataref =~ s/Ö/O/g;
	$$dataref =~ s/ø/o/g;
	$$dataref =~ s/æ/ae/g;
	$$dataref =~ s/\// /g;
}

sub do_initial_chars {
	my ($self, $dataref) = @_;
	$$dataref =~ s/FC/Fc/g;	
	$$dataref =~ s/AFC/Afc/g;
	$$dataref =~ s/SJK/SJk/g;
	$$dataref =~ s/AIK/AIk/g;
#	Order is important here !
	$$dataref =~ s/ FF//g;	# Swedish
	$$dataref =~ s/IFK //g;	
	$$dataref =~ s/FK //g;	
	$$dataref =~ s/ FK//g;	
	$$dataref =~ s/GIF //g;	
	$$dataref =~ s/ IF//g;	
	$$dataref =~ s/IF //g;	
	$$dataref =~ s/IK //g;	
	$$dataref =~ s/ SK//g;	
	$$dataref =~ s/BK //g;	
	$$dataref =~ s/ BK//g;	
	$$dataref =~ s/ SC//g;	
	$$dataref =~ s/ 08//g;
	$$dataref =~ s/KuPS/KUPS/g; # Finnish
	$$dataref =~ s/RoPS //g;
	$$dataref =~ s/ fB/ fb/g;
	$$dataref =~ s/jyskE/jyske/g; # Danish
}

sub revert {
	my ($self, $dataref) = @_;
	$$dataref =~ s/Fc/FC/g;
	$$dataref =~ s/Afc/AFC/g;
	$$dataref =~ s/AIk/AIK/g;
	$$dataref =~ s/KUPS/KuPS/g;
	$$dataref =~ s/SJk/SJK/g;
}

=pod

=head1 NAME

Fixtures_Model.pm

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
