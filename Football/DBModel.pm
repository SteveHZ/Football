package Football::DBModel;

use DBI;
use SQL::Abstract;

use MyLib qw(wordcase);
use MyKeyword qw(TESTING);
TESTING { use Data::Dumper; }

use Mu;
use namespace::clean;

ro 'data';

sub BUILD {
	my $self = shift;

	$self->{dbh} = DBI->connect ('DBI:CSV:', undef, undef, {
		f_dir => $self->{data}->{path},
		f_ext => '.csv',
		csv_eol => "\n",
		RaiseError => 1,
	})	or die "Couldn't connect to database : ".DBI->errstr;

	$self->{sqla} = SQL::Abstract->new ();
	$self->{leagues} = $self->build_leagues ();

	$self->{ha_team}= {
		'h' => 'HomeTeam',
		'a' => 'AwayTeam',
	};
	$self->{results_hash} = {
		'H' => {
			'W' => 'H',
			'L' => 'A',
			'D' => 'D',
		},
		'A' => {
			'W' => 'A',
			'L' => 'H',
			'D' => 'D',
		},
	};
}

sub DESTROY {
	my $self = shift;
	$self->{dbh}->disconnect;
}

sub build_leagues {
	my $self = shift;
	my $csv_leagues = $self->{data}->{leagues};
	my %leagues = ();

	for my $league (@$csv_leagues) {
		print "\nBuilding $league..";

		my $query = "select distinct HomeTeam from $league";
		my $sth = $self->{dbh}->prepare ($query)
			or die "Couldn't prepare statement : ".$self->{dbh}->errstr;
		$sth->execute;

		my @temp = ();
		while (my $row = $sth->fetchrow_hashref) {
			push @temp, $row->{HomeTeam};
		}
		$leagues{$league} = \@temp;
	}
	return \%leagues;
}

sub find_league {
	my ($self, $team) = @_;
	my $csv_leagues = $self->{data}->{leagues};
	for my $league (@$csv_leagues) {
		return $league if grep { $_ =~ /$team/ } $self->{leagues}->{$league}->@*;
	}
	return 0;
}

sub do_cmd_line {
	my ($self, $cmd_line) = @_;
	my ($team, @opts) = split ' -', $cmd_line;

	$team = wordcase ($team);
	$team =~ s/Fc/FC/;
	$opts[0] = 'ha'  if @opts == 0; # use defaults if not present
	$opts[1] = 'wld' if @opts == 1;	# as above
	$_ =~ s/ // for @opts;

	return ($team, \@opts);
}

sub get_homeaway {
	my ($self, $options) = @_;
	return @$options [0];
}

sub do_query {
	my ($self, $league, $team, $opts) = @_;

	my $query = $self->build_query ($team, $opts);
    my ($stmt, @bind) = $self->{sqla}->select ($league, '*', $query);
	TESTING {
		print "\nStatement = $stmt\n";
		print "\nBind =\n".Dumper [ @bind ];
#		<STDIN>;
	}

	my $sth = $self->{dbh}->prepare ($stmt)
		or die "Couldn't prepare statement : ".$self->{dbh}->errstr;
	$sth->execute (@bind);
	return $sth;
}

sub build_query {
	my ($self, $team, $opts) = @_;
	my @home_or_away = split '', @$opts[0];
	my @options = map { uc $_ } split '', @$opts[1];
	my @query = ();

	for my $ha (@home_or_away) {
		my @results = map { $self->{results_hash}->{uc $ha}->{$_} } @options;
		push @query, {
			FTR => [ @results ],								# (FTR = ? OR FTR = ?)...
			$self->{ha_team}->{$ha} => { -like => "%$team%" },	# HomeTeam/AwayTeam LIKE ?
		};
	}
	my %qhash = (-or => [ @query ]);
	TESTING {
		print Dumper { %qhash };
	}
	return \%qhash;
}

=pod

=head1 NAME

DBModel.pm

=head1 SYNOPSIS

Used by db.pl

=head1 DESCRIPTION

=head1 AUTHOR

Steve Hope 2018

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
