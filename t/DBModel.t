use strict;
use warnings;
use Data::Dumper;

use lib 'C:/Mine/perl/Football';
use Football::DBModel;
use SQL::Abstract;
use Test::More tests => 2;

my $sqla;

subtest 'constructor' => sub {
	$sqla = SQL::Abstract->new ();
	isa_ok ($sqla, 'SQL::Abstract', '$sqla');
};

subtest 'wtf' => sub {
	my $model = Football::DBModel->new ();

	my $cmd_line = 'Stoke -ha -wd';
	my ($team, $options) = $model->do_cmd_line ($cmd_line);

	is ($team, 'Stoke', "team = 'Stoke'");
	is (@$options [0], 'ha', 'option 1 = ha');
	is (@$options [1], 'wd', 'option 2 = wd');

	my $qhash = $model->build_query ($team, $options);
	my($stmt2, @bind2) = $sqla->select('E0', '*', $qhash);
	print "\nstatement = \n$stmt2\n";
	print "\nBind values = \n".Dumper @bind2;

	print "\nMy Query = \n".Dumper %$qhash;
};
