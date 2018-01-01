#!	C:/Strawberry/perl/bin

#	euro_benchmark.pl 19/07/17

use strict;
use warnings;

use lib 'C:/Mine/perl/Football';
use Football::Globals qw( $month_names );
use Benchmark qw(:all);

my $in_path = "C:/Mine/perl/Football/data/Euro/scraped/";
my @days = ("Friday ","Saturday ","Sunday ","Monday ","Tuesday ","Wednesday ","Thursday ");
my @months = qw(February March April May);

my $filename = $in_path."USA April".".txt";
open my $fh, '<', $filename or die "Can't open $filename !!";
chomp ( my $data = <$fh> );

my $t = timethese ( -10, {
	"prepare 2" => sub {
		my $copy = $data;
		prepare_2 (\$copy);
	},
	"prepare 3" => sub {
		my $copy = $data;
		prepare_3 (\$copy);
	},
	"prepare 4" => sub {
		my $copy = $data;
		prepare_4 (\$copy);
	},
});

cmpthese $t;

sub prepare_1 {
	my $dataref = shift;
	
	$$dataref =~ s/^.*Content//;
	$$dataref =~ s/All times are UK.*$//g;

	$$dataref =~ s/$_/#$_/g for @days;
	$$dataref =~ s/$_/$_\n/g for @months;

	$$dataref =~ s/Eastern Conference//g;
	$$dataref =~ s/FT/\n/g;

	my @lines = split /\n/,$$dataref;
	return \@lines;
}

sub prepare_2 {
	my $dataref = shift;
	
	$$dataref =~ s/^.*Content//;
	$$dataref =~ s/All times are UK.*$//g;

	$$dataref =~ s/(Friday |Saturday |Sunday |Monday |Tuesday |Wednesday |Thursday )/#$1/g;
	$$dataref =~ s/(February|March|April|May)/$1\n/g;

	$$dataref =~ s/Eastern Conference//g;
	$$dataref =~ s/FT/\n/g;

	my @lines = split /\n/,$$dataref;
	return \@lines;
}

sub prepare_3 {
	my $dataref = shift;
	
	$$dataref =~ s/^.*Content//;
	$$dataref =~ s/All times are UK.*$//g;

	$$dataref =~ s/((Fri|Sat|Sun|Mon|Tue|Wed|Thu).*day )/#$1/g;
	$$dataref =~ s/(February|March|April|May)/$1\n/g;

	$$dataref =~ s/Eastern Conference//g;
	$$dataref =~ s/FT/\n/g;

	my @lines = split /\n/,$$dataref;
	return \@lines;
}

sub prepare_4 {
	my $dataref = shift;
	
	$$dataref =~ s/^.*Content//;
	$$dataref =~ s/All times are UK.*$//g;

	$$dataref =~ s/((?:Fri|Sat|Sun|Mon|Tue|Wed|Thu).*day )/#$1/g;
	$$dataref =~ s/(February|March|April|May)/$1\n/g;

	$$dataref =~ s/Eastern Conference//g;
	$$dataref =~ s/FT/\n/g;

	my @lines = split /\n/,$$dataref;
	return \@lines;
}
