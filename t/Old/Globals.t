use strict;
use warnings;

use lib 'C:/Mine/perl/Football';
use MyDate qw(month_number);
#use Football::Globals qw(month_number);
use Test::More tests => 2;

subtest 'constructor' => sub {
	plan tests => 1;
	my $dt = MyDate->new ();
	isa_ok ($dt, 'MyDate', '$dt');
#	my $fg = Football::Globals->new ();
#	isa_ok ($fg, 'Football::Globals', '$fg');
};

subtest 'month_number' => sub {
	plan tests => 3;
	is (month_number ('January'), '01', 'January = 01');
	is (month_number ('Feb'), '02', 'Feb = 02');
	is (month_number ('Dece'), 0, 'Dece = 0'); 
};
