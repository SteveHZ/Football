use Test2::V0;
plan 2;
use Data::Dumper;

use lib 'C:/Mine/perl/Football';
use Football::DBModel;
use Football::Globals qw( @csv_leagues );
use SQL::Abstract;

my $sqla;

subtest 'constructor' => sub {
	plan 1;
	$sqla = SQL::Abstract->new ();
	isa_ok ($sqla, ['SQL::Abstract'], '$sqla');
};

subtest 'options' => sub {
	plan 3;
	my $data = get_uk_data ();
	my $model = Football::DBModel->new (data => $data);

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

	sub get_uk_data {
		return {
			leagues	=> \@csv_leagues,
			column	=> 'b365',
			path	=> 'C:/Mine/perl/Football/data',
			model	=> 'UK',
		}
	}
};
