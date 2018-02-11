#!	C:/Strawberry/perl/bin

#	Model.t 01/05/16, 07/11/17

use strict;
use warnings;
use Test::More tests => 1;
use Test::Deep;

use lib "C:/Mine/perl/Football";
use Football::Model;
use MyJSON qw(read_json);

my $unique_file = "test data/unique leagues.json";

subtest 'unique_leagues' => sub {
	plan tests => 1;
	
	my $model = Football::Model->new ();
	my $expect = read_json ($unique_file);
	
	my $fixtures = $model->get_fixtures ( testing => 1 );
	my $leagues = $model->get_unique_leagues ($fixtures);
	cmp_deeply ($leagues, $expect, 'got unique leagues');
};

=head1
#	original version

sub _get_unique_leagues {
	my $fixtures = shift;

	my %mapped = map {$_->{league_idx} => $_->{league} } @$fixtures;
	my @array = sort { $a <=> $b } keys %mapped;
	my @sorted;

	for my $idx (@array) {
		push (@sorted, {
			league_idx => $idx,
			league => $mapped{$idx},
		});
	}
	return \@sorted;
}
