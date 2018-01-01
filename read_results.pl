
#	read_results.pl 09/01/17

use strict;
use warnings;

use Spreadsheet::Read qw(rows);
use Data::Dumper;

my $path = "C:/Mine/perl/Football/data/Rugby/";
my $filename1 = $path."test_results.ods";
my $filename2 = $path."test_results2.ods";
my $leagues = [ "Super League", "Championship", "League One", "NRL" ];

main ();

sub main {
	my $games = {};
	
	my $data = ods_update ($filename1);
	append ($games, $data, $leagues);
	print Dumper $games;
	<STDIN>;

	$data = ods_update ($filename2);
	append ($games, $data, $leagues);
	print Dumper $games;
}

sub ods_update {
	my $filename = shift;
	my $book = Spreadsheet::Read->new ($filename);
	my @sheetnames = $book->sheets;
	my $games = {};
	my ($home_score, $away_score);
	
	for my $sheet (1..scalar @sheetnames) {
		my $league = $sheetnames [$sheet - 1];
		$games->{$league} = ();

		my @rows = rows ($book->[$sheet]);
		for my $row (@rows [1..$#rows]) {
			die "\nRead error in $filename" unless @$row[3] =~ /\d+[-.]\d+/;
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

sub append {
	my ($games, $data, $leagues) = @_;
	
	for my $league (@$leagues) {
		for my $row ( @{ $data->{$league} } ) {
			push ( @{ $games->{$league} }, $row );
		}
	}
}

=head
sub main {
	print "\nReading data...";
	my $book = Spreadsheet::Read->new ($filename);
	my @sheetnames = $book->sheets;
	my $games = {};
	my ($home_score, $away_score);
	
	print "\n$_" for @sheetnames;
	for my $sheet (1..scalar @sheetnames) {
		my $league = $sheetnames [$sheet - 1];
		print "\nReading $league...";
		$games->{$league} = ();
		my @rows = rows ($book->[$sheet]);
		print "\n";
		for my $row (@rows [1..$#rows]) {
			print "\n";
			print "$_ ," for @$row;

			die "\nRead error in $filename" unless @$row[3] =~ /(\d+)[-.](\d+)/;
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
<STDIN>;
use Data::Dumper;
print Dumper $games;
}
=cut