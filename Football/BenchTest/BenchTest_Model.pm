package Football::BenchTest::BenchTest_Model;

use List::MoreUtils qw(pairwise);
use Football::Globals qw(@csv_leagues @league_names);
use MyJSON qw(write_json);

use Moo;
use namespace::clean;

has 'league_hash' => (is => 'ro', lazy => 1, builder => '_build_league_hash');
has 'backup_path' => (is => 'ro', default => 'C:/Mine/perl/Football/data/benchtest/history/');

sub _build_league_hash {
    return { pairwise { $a => $b } @league_names, @csv_leagues };
}

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

sub do_backup {
    my ($self, $date, $data) = @_;
    my $filename = $self->{backup_path}."goal expect $date.json";
    print "\nWriting $filename...";
    write_json ($filename, $data);
}

1;
