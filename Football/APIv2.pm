package Football::APIv2;

#	Football::APIv2.pm 12/07/17

use DBI;

use Moo;
use namespace::clean;

sub BUILD {
	my $self = shift;
	$self->{dbh} = DBI->connect ("DBI:CSV:", undef, undef, {
		f_dir => "data",
		f_ext => ".csv",
		csv_eol => "\n",
		RaiseError => 1,
	})	or die "Couldn't connect to database : ".DBI->errstr;
}

sub DESTROY {
	my $self = shift;
	$self->{dbh}->disconnect;
}

sub query {
	my ($self, $query) = @_;
	my @result;
	
	my $sth = $self->{dbh}->prepare ($query)
		or die "Couldn't prepare statement : ".$self->{dbh}->errstr;
	$sth->execute;
	while (my $row = $sth->fetchrow_hashref) {
		push @result, $row;
	}
	return \@result;
}

1;

=head

sub update_dbi  {
	my ($self, $file) = @_;
	my @league_games = ();
		
	my $dbh = DBI->connect ("DBI:CSV:", undef, undef, {
		f_dir => "data",
		f_ext => ".csv",
		csv_eol => "\n",
		RaiseError => 1,
	})	or die "Couldn't connect to database : ".DBI->errstr;
	
	my $query = "select Date, HomeTeam, AwayTeam, FTHG, FTAG from $file";
	my $sth = $dbh->prepare ($query)
		or die "Couldn't prepare statement : ".$dbh->errstr;
	$sth->execute;

	while (my $row = $sth->fetchrow_hashref) {
		if ($self->{full_data}) {
			push ( @league_games, {
				date => $row->{Date},
				home_team => $row->{HomeTeam},
				away_team => $row->{AwayTeam},
				home_score => $row->{FTHG},
				away_score => $row->{FTAG},
				half_time_home => $row->{HTHG},
				half_time_away => $row->{HTAG},
			});
		} else {
			push ( @league_games, {
				date => $row->{Date},
				home_team => $row->{HomeTeam},
				away_team => $row->{AwayTeam},
				home_score => $row->{FTHG},
				away_score => $row->{FTAG},
			});
		}
	}
	$dbh->disconnect;
	return \@league_games;
}
=cut