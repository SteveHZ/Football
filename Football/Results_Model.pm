package Football::Results_Model;

use v5.010; # say
use MyKeyword qw(PRODUCTION DELETEALL);
use Web::Query;
use Football::Globals qw( $season $next_season);
use MyDate qw(@days_of_week $month_names);
use MyRegX;
use Data::Dumper;
use Moo;
use namespace::clean;

$Web::Query::UserAgent = LWP::UserAgent->new (
    agent => 'Mozilla/5.0',
);

my $leagues = [ qw(welsh-premier-league irish-premiership) ];
my $months = [ qw(08 09 10 11 12 01 02 03 04 05) ]; # August -> May
my $site_home = 'https://www.bbc.co.uk/sport/football/';

my $rx = MyRegX->new ();
my $date_parser = $rx->date_parser_without_year;

sub prepare {
	my ($self, $dataref) = @_;

#	Remove beginning and end of data
	$$dataref =~ s/^.*Content//g;
	$$dataref =~ s/All times.*$//g;
    $$dataref =~ s/FT/\n/g;

    $$dataref =~ s/($date_parser)/\n<DATE>$1\n/g;
	my @lines = grep { $_ ne '' } split '\n', $$dataref;
	return \@lines;
}

sub after_prepare {
	my ($self, $games) = @_;
	my $date;
    my @fixed_lines = ();

	for my $line (@$games) {
		if ($line =~ /^<DATE>$date_parser/ ) {
			$date = do_dates ( \%+ );
		} else {
			$line =~ s/(\D+)(\d\d?)(\D+)(\d\d?)/$date,$1,$3,$2,$4/;
            push @fixed_lines, $line;
        }
	}
	return $self->sort_games ( \@fixed_lines );
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
    my $year = ($month >= 8) ? substr $season,2,2 : substr $next_season,2,2;
	return "$date/$month/$year";
}

sub get_pages {
	my ($self, $leagues) = @_;
    my $pages = get_year_month_pages ($leagues, $months);
    my %files = ();

    for my $league (keys %$pages) {
        for my $page (@{ $pages->{$league} }) {
            my $filename = $page;
            $filename =~ s/.*football\/(.*)\/.*fixtures\/(\d{4}-\d{2}).*$/$1 $2/;
            push @{ $files{$league} }, $filename;

PRODUCTION {
            my $q = wq ($page);
    		if ($q) {
                $q->find ('abbr')
                  ->filter ( sub { $_->text ne 'FT' } )
                  ->replace_with ( '<b></b>' );

    			print "\nDownloading $page";
    			print "\n$filename : ";
    			$self->do_write ($filename, $q->text);
    			print "Done - character length : ".length ($q->text);
                sleep 1;
    		} else {
    			print "\nUnable to create object : $league->{name}";
    		}
}
        }
    }
    return \%files;
}

sub do_write {
	my ($self, $page, $txt) = @_;
	my $filename = "C:/Mine/perl/Football/data/Euro/scraped/$page.txt";

	open my $fh, '>', $filename or die "Can't open $filename";
	print $fh $txt;
	close $fh;
}

sub get_year_month_pages {
    my ($leagues, $months) = @_;
    my $current_month = get_current_month ();
    my $year_month_pages = get_ym_pages ($months);
    my %pages = ();

    for my $league (@$leagues) {
        my $flag = 0;
        my $site = $site_home."$league/scores-fixtures/";
        for my $year_month (@$year_month_pages) {
            my $page = $site.$year_month;
            if ($year_month =~ /-$current_month$/) {
                $page .= '?filter=results';
                $flag = 1;
            }
            push @{ $pages{$league} }, $page;
            last if $flag;
        }
    }
    return \%pages;
}

sub get_current_month {
    my @date = localtime;
    return sprintf "%02d", $date[4] + 1;
}

sub get_ym_pages {
    my $months = shift;
    return [
        map {
            ($_ >= 8) ?
                "$season-$_" :      # Aug - Dec
                "$next_season-$_"   # Jan - May
        } @$months
    ];
}

sub delete_all {
	my ($self, $path, $files) = @_;
    for my $league (keys %$files) {
        for my $file (@{ $files->{$league} }) {
            unlink "$path/$file.txt";
        }
    }
}

1;
