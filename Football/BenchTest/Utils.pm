package Football::BenchTest::Utils;

use Moo;
use strict;
use warnings;
use Exporter 'import';
use vars qw (@EXPORT_OK %EXPORT_TAGS);

@EXPORT_OK	 = qw (get_league make_csv_file_list make_file_list);
%EXPORT_TAGS = (all => \@EXPORT_OK);

sub get_league {
	my ($fixture_list, $league_name) = @_;
	return [ grep { $_->{league} eq $league_name } @$fixture_list ];
}

sub make_csv_file_list {
	my ($path, $file_list) = @_;
	return make_file_list ($path, [ map {"$_.csv"} @$file_list ] );
}

sub make_file_list {
	my ($path, $file_list) = @_;
	return [ map { "$path/$_"} @$file_list];
}

sub remove_postponed {
	my $data = shift;
	return [ grep { defined $_->{result} } @$data ];
}

1;
