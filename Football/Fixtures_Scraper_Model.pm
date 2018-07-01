package Football::Fixtures_Scraper_Model;

use Web::Query;
use Moo;
use namespace::clean;

$Web::Query::UserAgent = LWP::UserAgent->new (
    agent => 'Mozilla/5.0',
);

sub get_pages {
	my ($self, $site, $week) = @_;

	for my $date (@$week) {
		my $q = wq ("$site/$date->{date}");
		if ($q) {
			$q->find ('abbr')
			  ->filter ( sub { $_->text ne 'FT' } )
			  ->replace_with ( '<b></b>' );

			print "\nDownloading $date->{date}";
			print "\n$date->{date} : ";
			$self->do_write ($date->{date}, $q->text);
			print "Done - character length : ".length ($q->text);
		} else {
			print "\nUnable to create object : $site/$date->{date}";
		}
	}
	print "\n";
}

sub do_write {
	my ($self, $date, $txt) = @_;
	my $filename = "C:/Mine/perl/Football/data/Euro/scraped/fixtures $date.txt";

	open my $fh, '>', $filename or die "Can't open $filename";
	print $fh $txt;
	close $fh;
}

#	$self->{scraper} = Football::Web_Scraper_Model->new (
#		site => "$site",
#		code => sub {
#			my $q = shift;
#			return $q->find ('abbr')
#					 ->filter ( sub { $_->text ne 'FT' } )
#					 ->replace_with ( '<b></b>' );
#		}
#	);

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
