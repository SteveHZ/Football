package Summer::Summer_Data_Model;

use Moo;
use namespace::clean;

use lib "C:/Mine/perl/Football";
use Football::Utils qw(get_euro_odds_cols);
use Euro::Rename qw( check_rename );

# Read Football Data csv files

sub read_data {
	my ($self, $file) = @_;
	my $league_games = [];

	open (my $fh, '<', $file) or die ("Can't find $file");
	my $line = <$fh>;
	my @odds_cols = get_euro_odds_cols ($line);

	while ($line = <$fh>) {
		chomp $line;
		my @data = split (',', $line);
		last if $data [0] eq ""; # don't remove !!!
		
		push ( @$league_games, {
			league => $data [0],
			year => $data [2],
			date => $data [3],
			home_team => $data [5],
			away_team => $data [6],
			home_score => $data [7],
			away_score => $data [8],
			result => $data [9],
			home_odds => $data [ $odds_cols[0] ],
			draw_odds => $data [ $odds_cols[1] ],
			away_odds => $data [ $odds_cols[2] ],
		});
		
	}
	close $fh;
	return $league_games;
}

# Write my csv files using data from read_data method

sub write_csv {
	my ($self, $file, $data) = @_;
	open (my $fh, '>', $file) or die ("Unable to open $file");

	print $fh "Date,HomeTeam,AwayTeam,FTHG,FTAG,FTR,AvgH,AvgD,AvgA";
	for my $line (@$data) {
		$line->{home_team} = check_rename ( $line->{home_team} );
		$line->{away_team} = check_rename ( $line->{away_team} );
	
		print $fh "\n". $line->{date} .",".
						$line->{home_team} .",". $line->{away_team} .",".
						$line->{home_score}.",". $line->{away_score}.",". $line->{result}.",".
						$line->{home_odds} .",". $line->{draw_odds} .",". $line->{away_odds};
	}
	close $fh;
}

# Read my csv files created by write_csv method

sub read_csv {
	my ($self, $file) = @_;
	my $league_games = [];

	open (my $fh, '<', $file) or die ("Can't find $file");
	my $line = <$fh>;

	while ($line = <$fh>) {
		chomp $line;
		my @data = split (',', $line);
		last if $data [0] eq ""; # don't remove !!!
		
		push ( @$league_games, {
			date => $data [0],
			home_team => $data [1],
			away_team => $data [2],
			home_score => $data [3],
			away_score => $data [4],
			result => $data [5],
			home_odds => $data [6],
			draw_odds => $data [7],
			away_odds => $data [8],
		});
	}
	close $fh;
	return $league_games;
}

=head1
sub update_euro {
	my ($self, $file) = @_;
	my $league_games = [];

	open (my $fh, '<', $file) or die ("Can't find $file");
	my $line = <$fh>;
	my @odds_cols = get_euro_odds_cols ($line);

	while ($line = <$fh>) {
		chomp $line;
		my @data = split (',', $line);
		last if $data [0] eq ""; # don't remove !!!
		
		if ($data [2] eq "2017") {
			push ( @$league_games, {
				league => $data [0],
				year => $data [2],
				date => $data [3],
				home_team => $data [5],
				away_team => $data [6],
				home_score => $data [7],
				away_score => $data [8],
				result => $data [9],
				home_odds => $data [ $odds_cols[0] ],
				draw_odds => $data [ $odds_cols[1] ],
				away_odds => $data [ $odds_cols[2] ],
			});
		}
	}
	close $fh;
	return $league_games;
}
=cut

=pod

=head1 NAME

Euro_Data_Model.pm

=head1 SYNOPSIS

Used by fetch_euro.pl and euro_profit.pl

=head1 DESCRIPTION

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;