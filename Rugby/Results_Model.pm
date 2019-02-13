package Rugby::Results_Model;

use Web::Query;
use Rugby::Globals qw(@fixtures_leagues $results_season);
use MyDate qw(@days_of_week $month_names);
use MyRegX;
use Data::Dumper;
use Moo;
use namespace::clean;

$Web::Query::UserAgent = LWP::UserAgent->new (
    agent => 'Mozilla/5.0',
);

my $weekdays = join '|', @days_of_week;
my $leagues = join '|', @fixtures_leagues;

my $rx = MyRegX->new ();
my $date_parser = $rx->rugby_results_date_parser;

sub prepare {
	my ($self, $dataref) = @_;

#	Remove beginning and end of data
#	$$dataref =~ s/^.*Betfred ($leagues)//;
#    $$dataref =~ s/^.*Telstra Premiership//;
$$dataref =~ s/^.*Content//;
$$dataref =~ s/All times are UK.*$//g;
#	$$dataref =~ s/Please note.*$//g;

#	Remove whitespace and other stuff
#	$$dataref =~ s/\s{2}+//g;
	$$dataref =~ s/Super 8s|Shield|Grand Final|Semi-|final|Final|Play-off //g;

print Dumper $$dataref;<STDIN>;
#	Find dates
    $$dataref =~ s/($date_parser)/\n<DATE>$1\n/g;
print Dumper $$dataref;
<STDIN>;
#die;
#	Find games - without positive lookahead (?=\D) this matches on the year so 2018 -> 20\n18
    $$dataref =~ s/(\D+\d{1,3}\D+\d{1,3}(?=\D))/$1\n/g;

	my @lines = grep { $_ ne '' } split '\n', $$dataref;
	shift @lines;
	return \@lines;
}

sub after_prepare {
	my ($self, $games) = @_;
	my $date;

	for my $line (@$games) {
		if ($line =~ /^<DATE>$date_parser/ ) {
			$date = do_dates ( \%+ );
		} else {
            $line =~ s/\s*(\D+)(\d{1,3})\s*(\D+)(\d{1,3})/$date,$1,$3,$2,$4/;
		}
	}
	return $self->sort_games ( $games );
}

#	Reverse list to run from earliest date first,
#	keeping alphabetical order for each date
sub sort_games {
	my ($self, $games) = @_;

	return [
		map { "$_->[1],$_->[2],$_->[3],$_->[4],$_->[5]" }
		sort {
			$a->[0] <=> $b->[0] 	# date_cmp
			or $a->[2] cmp $b->[2] 	# home_team
		}
		map {
			[ $self->get_date_cmp (\$_), split (',', $_) ]
		}
		grep { $_ =~ /\/$results_season/ }
		@$games
	];
}

sub get_date_cmp {
	my ($self, $dateref) = @_;
	return "$3$2$1" if $$dateref =~ m{^(\d\d)/(\d\d)/(\d\d)};
	return 0;
}

sub do_dates {
	my $hash = shift;

	my $date = sprintf "%02d", $hash->{date};
	my $month = $month_names->{ $hash->{month} };
	my $year = substr $hash->{year},2,2;
	return "$date/$month/$year";
}

sub get_pages {
	my ($self, $leagues) = @_;

	for my $league (@$leagues) {
		my $q = wq ("$league->{site}");
		if ($q) {
            $q->find ('abbr')   # ->filter ( sub { $_->text ne 'FT' } )
              ->replace_with ( '<b></b>' );
			print "\nDownloading $league->{site}";
			print "\n$league->{name} : ";
			$self->do_write ($league->{name}, $q->text);
			print "Done - character length : ".length ($q->text);
            sleep 1;
        } else {
			print "\nUnable to create object : $league->{name}";
		}
	}
	print "\n";
}

sub do_write {
	my ($self, $page, $txt) = @_;
	my $filename = "C:/Mine/perl/Football/data/Rugby/scraped/$page.txt";

	open my $fh, '>', $filename or die "Can't open $filename";
	print $fh $txt;
	close $fh;
}

1;
