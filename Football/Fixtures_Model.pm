package Football::Fixtures_Model;

use Football::Globals qw(@csv_leagues @summer_csv_leagues @euro_csv_lgs);
use Football::Fixtures_Globals qw(%football_fixtures_leagues %rugby_fixtures_leagues);
use Football::Fixtures_Scraper_Model;
use MyRegX;
use MyDate qw( $month_names );
use MyKeyword qw(TESTING);

use Time::Piece qw(localtime);
use Time::Seconds qw(ONE_DAY);
use Data::Dumper;

TESTING { use utf8; }

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
	$self->{files} = _transform_hash (get_league_hash ());
}

sub get_pages {
	my ($self, $sites, $week) = @_;
	for my $site (@$sites) {
		$self->{scraper}->get_football_pages ($site, $week);
	}
}

sub get_league_hash {
TESTING {
	return {
		uk 		=> \@csv_leagues,
		euro 	=> \@euro_csv_lgs,
		summer 	=> \@summer_csv_leagues,
}};
	return {
		uk      => \@csv_leagues,
		euro    => \@euro_csv_lgs,
		summer  => \@summer_csv_leagues,
	};
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
	my $files = $self->{files};
	my $fixed_lines = {};
	my $csv_league = '';

	for my $line (@$lines) {
		if ($line =~ /^<LEAGUE>(.*)$/) {
			$csv_league = (exists $football_fixtures_leagues{$1} ) ?
				$football_fixtures_leagues{$1} : 'X';
		}
		next if $csv_league eq 'X';
		if ($line =~ /\d:\d/) { # valid lines will have a time eg 15:00
			$line =~ s/($dm_date),(.*),($time),(.*)/$1 $3,$csv_league,$2,$4/;
			push @{ $fixed_lines->{ $files->{$csv_league}} }, $line;
		}
	}
	return $fixed_lines;
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
	$days //= 7;
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

sub get_reverse_week {
	my ($self, $days) = @_;
	$days //= 10;
	$self->get_week ($days, 0);
}

sub do_foreign_chars {
	my ($self, $dataref) = @_;
	$$dataref =~ s/$_/a/g for (qw(ä å));
	$$dataref =~ s/$_/o/g for (qw(ö ø));
	$$dataref =~ s/é/e/g;
	$$dataref =~ s/Ú/e/g; # for test
	$$dataref =~ s/Ö/O/g;
	$$dataref =~ s/ü/u/g;
	$$dataref =~ s/æ/ae/g;
}

sub do_initial_chars {
	my ($self, $dataref) = @_;
	$$dataref =~ s/(Serie|Division) A/$1 a/g;
	$$dataref =~ s/French Ligue 1/French Ligue 1x/g;

#	Order is important here !
	$$dataref =~ s/FC/Fc/g;
	$$dataref =~ s/AFC/Afc/g;
	$$dataref =~ s/SJK/SJk/g;
	$$dataref =~ s/AIK/AIk/g;
	$$dataref =~ s/MU/Mu/g;  # Welsh
	$$dataref =~ s/UCD/UCd/g; # Irish
	$$dataref =~ s/(?<!H)IFK //g;  # Swedish - DON'T match with HIFK, only IFK
	$$dataref =~ s/GIF //g;
	$$dataref =~ s/ FF//g;
	$$dataref =~ s/(?<!HI)FK //g; # NOT HIFK
	$$dataref =~ s/ FK//g;
	$$dataref =~ s/IF //g;
	$$dataref =~ s/ IF//g;
	$$dataref =~ s/IK //g;
	$$dataref =~ s/ SK//g;
	$$dataref =~ s/BK //g;
	$$dataref =~ s/ BK//g;
	$$dataref =~ s/ SC//g;
	$$dataref =~ s/SC //g;
	$$dataref =~ s/AC //g;
	$$dataref =~ s/ \d\d//g; #04,05,08,96
	$$dataref =~ s/SPAL/SPAl/g;
	$$dataref =~ s/VfB //g;  # German
	$$dataref =~ s/VfL //g;
	$$dataref =~ s/1\. //g;
	$$dataref =~ s/1899 //g;
	$$dataref =~ s/KuPS/KUPS/g; # Finnish
	$$dataref =~ s/RoPS //g;
	$$dataref =~ s/ fB/ fb/g;
	$$dataref =~ s/\// /g; # Norwegian (Bodo/Glimt)
	$$dataref =~ s/jyskE/jyske/g; # Danish
}

sub revert {
	my ($self, $dataref) = @_;
	$$dataref =~ s/Serie a/Serie A/g;
	$$dataref =~ s/Fc/FC/g;
	$$dataref =~ s/Afc/AFC/g;
	$$dataref =~ s/Mu(?!n)/MU/g; # Cardiff MU - but not Bayern Munich
	$$dataref =~ s/AIk/AIK/g;
	$$dataref =~ s/KUPS/KuPS/g;
	$$dataref =~ s/SJk/SJK/g;
	$$dataref =~ s/SPAl/SPAL/g;
	$$dataref =~ s/UCd/UCD/g;
}

#   transform a hash from key => value 'one-to-many' relationship
#   to a value => key 'many-to-one' relaationship.
#   eg transform uk=>[qw(E0 E1 E2 E3 EC)] to E0=>uk, E1=>uk, E2=>uk, E3=>uk, EC=>uk

sub _transform_hash {
    my $old_hash = shift;
    my %new_hash = ();
    for my $key (keys %$old_hash) {
		map { $new_hash{$_} = $key } @{ $old_hash->{$key} };
    }
    return \%new_hash;
}

#	wrapper for testing
sub transform_hash {
	TESTNG {
		my ($self, $hash) = @_;
		return _transform_hash ($hash);
	}
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
