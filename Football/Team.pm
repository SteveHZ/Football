package Football::Team;
 
#	Football::Team.pm 03/02/16

use strict;
use warnings;

my $default_stats_size = 6;

sub new {
	my $class = shift;
	my $self = {
		games => [],
	};
	
    bless $self, $class;
    return $self;
}

sub add {
	my ($self, $game) = @_;
	push (@ {$self->{games} }, $game);
}

sub games {
	my $self = shift;
	return @{$self->{games}};
}

sub iterator {
	my $self = shift;
	my $idx = 0;
	my $size = scalar (@{ $self->{games} });

	return sub {
		return undef if $idx == $size;
		return @{ $self->{games} }[$idx++];
	}
}

sub reverse_iterator {
	my $self = shift;
	my $idx = scalar (@{ $self->{games} }) - 1;

	return sub {
		return undef if $idx < 0;
		return @{ $self->{games} }[$idx--];
	}
}

sub get_homes {
	my ($self, $num_games) = @_;
	$num_games //= $default_stats_size;
	return $self->get_stats ('H', $num_games);
}

sub get_full_homes {
	my ($self, $num_games) = @_;
	$num_games //= $default_stats_size;
	return $self->get_full_stats ('H', $num_games);
}

sub get_aways {
	my ($self, $num_games) = @_;
	$num_games //= $default_stats_size;
	return $self->get_stats ('A', $num_games);
}

sub get_full_aways {
	my ($self, $num_games) = @_;
	$num_games //= $default_stats_size;
	return $self->get_full_stats ('A', $num_games);
}

sub get_stats {
	my ($self, $home_away, $num_games) = @_;

	my @results = ();
	my $temp = $self->get_full_stats ($home_away, $num_games);
	push @results, $_->{result} for @$temp;
	return \@results;
}

sub get_full_stats {
	my ($self, $home_away, $num_games) = @_;
	my ($start, $end);

	my @list = grep {$_->{home_away} eq $home_away} @{ $self->{games} };
	$end = scalar @list - 1;
	$start = $end - ($num_games - 1);

	my @spliced = splice (@list, $start, $end);
	return \@spliced;
}

sub most_recent {
	my ($self, $num_games) = @_;
	$num_games //= $default_stats_size;
	return $self->get_most_recent ($num_games);
}

sub get_most_recent {
	my ($self, $num_games) = @_;
	my ($start, $end);
	
	my @list = @ {$self->{games} };
	$end = scalar @list - 1;
	$start = $end - ($num_games - 1);
	
	my @results = ();
	my @spliced = splice (@list, $start, $end);
	push @results, $_->{result} for @spliced;
	return \@results;
}

1;
