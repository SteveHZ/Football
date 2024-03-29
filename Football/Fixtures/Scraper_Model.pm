package Football::Fixtures::Scraper_Model;

use Web::Query;
use MyLib qw(wordcase);
use utf8;

use Moo;
use namespace::clean;

$Web::Query::UserAgent = LWP::UserAgent->new (
    agent => 'Mozilla/5.0',
);

sub get_football_pages {
	my ($self, $site, $week) = @_;

	for my $date (@$week) {
		my $q = wq ("$site/$date->{date}");
		if ($q) {
			$q->find ('abbr')
			  ->filter ( sub { $_->text ne 'FT' } )
			  ->replace_with ( '<b></b>' );

			print "\nDownloading $date->{date}";
			print "\n$date->{date} : ";
			$self->do_football_write ($date->{date}, $q->text);
			print "Done - character length : ".length ($q->text);
            sleep 1;
		} else {
			die "\n\nSomething went wrong.\nUnable to create object : $site/$date->{date}";
		}
	}
	print "\n";
}

sub get_rugby_pages {
	my ($self, $site, $week) = @_;

	for my $date (@$week) {
		my $q = wq ("$site/$date->{date}");
		if ($q) {
			$q->find ('abbr')
			  ->filter ( sub { $_->text ne 'FT' } )
			  ->replace_with ( '<b></b>' );

			print "\nDownloading $date->{date}";
			print "\n$date->{date} : ";
			$self->do_rugby_write ($date->{date}, $q->text);
			print "Done - character length : ".length ($q->text);
            sleep 1;
		} else {
#			die "Cannot get a resource from $site: " . Web::Query->last_response()->status_line;
			print "\nUnable to create object : $site/$date->{date}";
		}
	}
	print "\n";
}

sub get_league_name {
	my $str = shift;
	$str =~ s/^.*\/(.*)\/fixtures/$1/;
	$str =~ s/-/ /g;
	return wordcase ($str);
}

sub do_football_write {
	my ($self, $date, $txt) = @_;
	my $filename = "C:/Mine/perl/Football/data/Euro/scraped/fixtures $date.txt";

	open my $fh, '>:utf8', $filename or die "Can't open $filename";
	print $fh $txt;
	close $fh;
}

sub do_rugby_write {
    my ($self, $date, $txt) = @_;
    my $filename = "C:/Mine/perl/Football/data/Euro/scraped/rugby $date.txt";

	open my $fh, '>:utf8', $filename or die "Can't open $filename";
	print $fh $txt;
	close $fh;
}

=pod

=head1 NAME

Fixtures_Scraper_Model.pm

=head1 SYNOPSIS

Used by Fixtures_Model.pl

=head1 DESCRIPTION

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
