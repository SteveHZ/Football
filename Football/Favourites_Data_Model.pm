package Football::Favourites_Data_Model;

use Moo;
use namespace::clean;

use List::MoreUtils qw(any);

sub update {
	my ($self, $file) = @_;
	my $league_games = [];

	open (my $fh, '<', $file) or die ("Can't find $file");
	my $line = <$fh>;	# skip first line
	while ($line = <$fh>) {
		my @data = (split ',', $line)[4..9];
		last if $data [0] eq ""; # don't remove !!!
		push ( @$league_games, {
			home_score => $data [0],
			away_score => $data [1],
			result => $data [2],
			home_odds => $data [3],
			draw_odds => $data [4],
			away_odds => $data [5],
		});
	}
	close $fh;
	return $league_games;
}

sub update_current {
	my ($self, $file, $csv_league) = @_;
	my $league_games = [];
	my @odds_cols = (23..25);
	
	if (any { $csv_league eq $_ } qw(SC1 SC2 SC3) ) {
		@odds_cols = (10..12);
	} elsif ($csv_league eq "EC") {
		@odds_cols = (15..17);
	}

	open (my $fh, '<', $file) or die ("Can't find $file");
	my $line = <$fh>;	# skip first line
	while ($line = <$fh>) {
		my @data = split (',', $line);
		last if $data [0] eq ""; # don't remove !!!

		push ( @$league_games, {
			league => $data [0],
			date => $data [1],
			home_team => $data [2],
			away_team => $data [3],
			home_score => $data [4],
			away_score => $data [5],
			result => $data [6],
			home_odds => $data [ $odds_cols[0] ],
			draw_odds => $data [ $odds_cols[1] ],
			away_odds => $data [ $odds_cols[2] ],
		});
	}
	close $fh;
	return $league_games;
}

sub write_current {
	my ($self, $file, $data) = @_;
	open (my $fh, '>', $file) or die ("Unable to open $file");

	print $fh "Div ,Date ,Home Team, Away Team, FTHG, ATHG, FTR, B365H, B365D, B365A";
	for my $line (@$data) {
		print $fh "\n". $line->{league} .",". $line->{date} .",".
						$line->{home_team} .",". $line->{away_team} .",".
						$line->{home_score}.",". $line->{away_score}.",". $line->{result}.",".
						$line->{home_odds} .",". $line->{draw_odds} .",". $line->{away_odds};
	}
	close $fh;
}

=pod

=head1 NAME

Favourites_Data_Model.pm

=head1 SYNOPSIS

Used by predict.pl

=head1 DESCRIPTION

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;