#!	C:/Strawberry/perl/bin

#	MyBessel_bench 01/10/17, 04/10/17, 12/10/17

use strict;
use warnings;

use lib '../../Football';
use Summer::Model;
use Data::Dumper;
use Benchmark qw(timethese cmpthese);

my $model = Summer::Model->new ();
my $games = $model->read_games ( "0" );
my $leagues = $model->build_leagues ($games);
my $table = @$leagues[0]->get_table ();
#print Dumper $table;
#die;

my $t = timethese (-10, {
	"sort 1" => sub {
		sort_table1 ($table);
	},
	"sort 2" => sub {
		sort_table2 ($table);
	},
	"sort 3" => sub {
		sort_table3 ($table);
	},
	"sort 4" => sub {
		sort_table4 ($table);
	}
});
cmpthese $t;

sub sort_table1 {
	my $self = shift;
	my $table = $self->{table};

	for my $team (
		sort {
			$table->{$b}->{points} <=> $table->{$a}->{points}
			or _goal_diff ($table->{$b}) <=> _goal_diff ($table->{$a})
			or $table->{$b}->{for} <=> $table->{$a}->{for}
			or $table->{$a}->{team} cmp $table->{$b}->{team}
		} keys %{$table}
	) {
		push (@ {$self->{sorted} }, $table->{$team} );
	}
	return \@ {$self->{sorted} };
} 	
sub sort_table2 {
	my $self = shift;
	my $table = $self->{table};

	return $self->{sorted} = [
		map  { $table->{$_} }
		sort {
			$table->{$b}->{points} <=> $table->{$a}->{points}
			or _goal_diff ($table->{$b}) <=> _goal_diff ($table->{$a})
			or $table->{$b}->{for} <=> $table->{$a}->{for}
			or $table->{$a}->{team} cmp $table->{$b}->{team}
		}
		keys %$table		
	];
} 	

sub sort_table3 {
	my $self = shift;
	my $table = $self->{table};

	return $self->{sorted} = [
		map  { $table->{ $_->[0] } }
		sort {
			$table->{ $b->[0] }->{points} <=> $table->{ $a->[0] }->{points}
			or $b->[1] <=> $a->[1] # goal_diff
			or $table->{ $b->[0] }->{for} <=> $table->{ $a->[0] }->{for}
			or $table->{ $a->[0] }->{team} cmp $table->{ $b->[0] }->{team}
		}
		map { 
			[ $_, _goal_diff ( $table->{$_} ) ]
		}
		keys %$table		
	];
#	return $self->{sorted};
} 	

sub sort_table {
	my $self = shift;
	my $table = $self->{table};

	return $self->{sorted} = [
		map  { $table->{ $_->[0] } }
		sort {
			$b->[1]    <=> $a->[1] 	# points
			or $b->[2] <=> $a->[2] 	# goal diff
			or $b->[3] <=> $a->[3] 	# goals for
			or $a->[0] cmp $b->[0] 	# team name
		}
		map { [
			$_,
			$table->{$_}->{points},
			_goal_diff ( $table->{$_} ),
			$table->{$_}->{for},
		] }
		keys %$table		
	];
} 	
