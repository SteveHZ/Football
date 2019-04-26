#!	C:/Strawberry/perl/bin

#	sort_table_bench.pl 17/08/18

use strict;
use warnings;

use Summer::Model;
use Benchmark qw(timethese cmpthese);

my $model = Summer::Model->new ();
my $games = $model->read_games ();
my $leagues = $model->build_leagues ($games);
my $table = @$leagues[0]->get_table ();

my $t = timethese (-10, {
	'sort 1' => sub {
		sort_table1 ($table);
	},
	'sort 2' => sub {
		sort_table2 ($table);
	},
	'sort 3' => sub {
		sort_table3 ($table);
	},
	'sort 4' => sub {
		sort_table4 ($table);
	},
	'sort 5' => sub {
		sort_table5 ($table);
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
		} keys %$table
	) {
		push (@ {$self->{sorted} }, $table->{$team} );
	}
	return $self->{sorted};
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
}

sub sort_table4 {
	my $self = shift;
	my $table = $self->{table};

	return $self->{sorted} = [
		map  { $table->{ $_->[0] } }
		sort {
			$b->{points} <=> $a->{points}
			or $b->{goal_diff} <=> $a->{goal_diff} # goal_diff
			or $b->{for} <=> $a->{for}
			or $a->{team} cmp $b->{team}
		}
		map { [
			team => $_,
			points => $table->{$_}->{points},
			goal_diff =>_goal_diff ( $table->{$_} ),
			for => $table->{$_}->{for},
		] }
		keys %$table
	];
}

sub sort_table5 {
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
=header
3421-4
4213-5
4321-10
4321-10
4312-10
3421-100
3421-100
4312-40
4132-40
4213-40
3421-40
32541
=cut
