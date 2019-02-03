package Football::BenchTest::BenchTest_Model;

use Moo;
use namespace::clean;

sub get_league {
	my ($self, $fixture_list, $league_name) = @_;
	return [ grep { $_->{league} eq $league_name } @$fixture_list ];
}

sub make_csv_file_list {
	my ($self, $path, $file_list) = @_;
	return make_file_list ($path, [ map {"$_.csv"} @$file_list ] );
}

sub make_file_list {
	my ($self, $path, $file_list) = @_;
	return [ map { "$path/$_"} @$file_list];
}

sub remove_postponed {
	my ($self, $data) = @_;
	return [ grep { defined $_->{result} } @$data ];
}

1;
