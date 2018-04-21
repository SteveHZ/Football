use strict;
use warnings;
use Data::Dumper;

use lib 'C:/Mine/perl/Football';
use Football::DBModel;
use SQL::Abstract;
use Test::More tests => 2;

my $sqla;

subtest constructor => sub {
	$sqla = SQL::Abstract->new ();
	isa_ok ($sqla, 'SQL::Abstract','$sqla');
};

subtest 'wtf' => sub {
	my $model = Football::DBModel->new ();
#	my %where = (-or =>[
#		{ home_team => 'Stoke', result => [ qw(H D) ]},
#		{ away_team => 'Stoke', result => [ qw(A D) ]},
#		{ home_team => 'Stoke', result => ['H','D']},
#		{ away_team => 'Stoke', result => ['A','D']},
#	]);

#	my($stmt, @bind) = $sqla->select('E0', '*',\%where);
#	print "\n$stmt\n";
#	print Dumper @bind;
	
	my $cmd_line = "Stoke -ha -wd";
#	my $cmd_line = "Man City -ha -ld";
	my ($team, $options) = $model->do_cmd_line ($cmd_line);

	is ($team, "Stoke", "team = 'Stoke'");
	is (@$options [0], "ha", "option 1 = ha");
	is (@$options [1], "wd", "option 2 = wd");
#SELECT * FROM SC2 WHERE ( ( FTR = ? AND HomeTeam = ? ) )
#SELECT * FROM SC2 WHERE ( ( AwayTeam = ? AND ( FTR = ? OR FTR = ? ) ) )
	my $qhash = $model->build_query ($team, $options);
	my($stmt2, @bind2) = $sqla->select('E0', '*',$qhash);
#	my($stmt2, @bind2) = $sqla->select('E0', '*',\%qhash);
	print "\nstatement = \n$stmt2\n";
	print "\nBind values = \n".Dumper @bind2;

#	print "\n\nEx Query = \n".Dumper %where;
	print "\nMy Query = \n".Dumper %$qhash;
};

=head
sub do_cmd_line {
	my $cmd_line = shift;
	my ($team, @opts) = split ' -', $cmd_line;
	return ($team, \@opts);
}

sub build_query {
	my ($team, $opts) = @_;
	my $venues = [ split //,@$opts[0] ];
	my $options = [ map { uc $_ } split //, @$opts[1] ];
	
	my $venue_hash = {
		'h' => 'home_team',
		'a' => 'away_team',
	};	
	my @q=();

	for my $venue (@$venues) {
		my $temp = {};
		$temp->{ $venue_hash->{$venue} } = $team;
		$temp->{results} = [ @$options ];
		push @q, $temp;
	}
	my %qhash = (-or => [@q]);
	return \%qhash;
}
sub get_options {
	my ($arg, $hash) = @_;
	my $options = {};
	for my $key (keys %$hash) {
		$options->{ $hash->{key} } = 1 if $arg =~ /$key/;
	}
}
	my $venues = [ split //,@$options[0] ];
	my $options = [ map { uc $_ } split //, @$options[1] ];
	my $venue_hash = {
		'h' => 'home_team',
		'a' => 'away_team',
	};	
	my @q=();

	for my $venue (@$venues) {
		my $temp = {};
		$temp->{ $venue_hash->{$venue} } = $team;
		$temp->{results} = [ @$options ];
		push @q, $temp;
	}
	my %qhash = (-or => [@q]);
=cut    


=head1

??
get team and args
team,args =
# / -/
split - re;eat abovw
return error unless @-3?
??

ha options ha
result options wld
agvx0 ha options
argv 1 options result options

my $option @option
 if $ =~ $option
hasj = 1

semd arrys to sqla
=cut 