package Rugby::Rugby_Data_Model;

use Spreadsheet::Read qw(rows);
use List::MoreUtils qw(any);

use Moo;
use namespace::clean;

sub update {
	my ($self, $games, $filename) = @_;

	print "\nReading $filename...";
	my $book = Spreadsheet::Read->new ($filename);
	die "\nProblem reading $filename" unless $book->sheets;

	my @sheetnames = $book->sheets;
	my ($home_score, $away_score);


	for my $sheet (1..scalar @sheetnames) {
		my $league = $sheetnames [$sheet - 1];
#print "\nleague = $league\n";<STDIN>;
		my @rows = rows ($book->[$sheet]);
		for my $row (@rows [1..$#rows]) {
			die "\nRead error in $filename : $league" unless @$row[3] =~ /\d+[-.]\d+/;
			($home_score, $away_score) = split ('[-.]', @$row[3]);

			push ( @{ $games->{$league} }, {
				date => @$row[0],
				home_team => @$row[1],
				away_team => @$row[2],
				home_score => $home_score,
				away_score => $away_score,
			});
		}
	}
	return $games;
}

sub write_csv {
	my ($self, $data, $path) = @_;

	for my $league (keys %$data) {
		my $filename = $path.$league.".csv";
		open my $fh, ">", $filename or die "Can't open $filename";

		print $fh 'Date,Home Team,Away Team,Home,Away';
		for my $game ( @{ $data->{$league} } ) {
			print $fh "\n".
				$game->{date}.','.
				$game->{home_team}.','.
				$game->{away_team}.','.
				$game->{home_score}.','.
				$game->{away_score};
		}
		close $fh;
	}
}

sub read_archived {
	my ($self, $file) = @_;
	my @league_games = ();

	open my $fh, '<', $file or die "Can't find $file";
	my $line = <$fh>;	# skip first line
	while ($line = <$fh>) {
		chomp ($line);
		my @data = split (',', $line);
		last if $data [0] eq ''; # don't remove !!!
		die "No result for $data[1] v $data[2]\n...in $file\n" if any {$_ eq ""} ( $data[3], $data[4] );

		push ( @league_games, {
			date => $data [0],
			home_team => $data [1],
			away_team => $data [2],
			home_score => $data [3],
			away_score => $data [4],
		});
	}
	close $fh;
	return \@league_games;
}

1;
