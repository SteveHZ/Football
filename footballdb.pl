#!	C:/Strawberry/perl/bin

#	footballdb.pl 17-19/06/17

use strict;
use warnings;

use DBI;
use Football::Football_Data_Model;
use Football::Globals qw(@csv_leagues);

main ();

sub main  {
	my $dsn = "DBI:SQLite:football.db";
	my $dbh = DBI->connect ($dsn, "root", "zappa")
		or die "Can't connect to database : ".DBI->errstr;

	my $data_model = Football::Football_Data_Model->new ();
	my $path = "C:/Mine/perl/Football/data/";
	
	for my $league (@csv_leagues) {
		my $filename = $path.$league.".csv";
		my $games = $data_model->update ($filename);
		
		my $query = "insert into games
			(date, league_id, home_team, home_score, away_team, away_score)
			values (?,?,?,?,?,?)";

		my $sth = $dbh->prepare ($query)
			or die "Can't prepare statement : ".$dbh->errstr;
		
		for my $game (@$games) {
			data_clean ($game);
			print "\n$game->{date} $game->{home_team} v $game->{away_team}";
			$sth->execute (
				$game->{date}, $league,
				$game->{home_team}, $game->{home_score},
				$game->{away_team}, $game->{away_score}
			);
		}
	}

	$dbh->disconnect ();
}

sub data_clean {
	my $game = shift;
	$game->{home_team} =~ s/'//;
	$game->{away_team} =~ s/'//;
}