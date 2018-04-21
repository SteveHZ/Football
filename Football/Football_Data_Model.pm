package Football::Football_Data_Model;

use List::MoreUtils qw(any);

use Moo;
use namespace::clean;

has 'full_data' => (is => 'rw', default => '0');

sub update {
	my ($self, $file, $full_data) = @_;
	my @league_games = ();
	
	open my $fh, '<', $file or die "Can't find $file";
	my $line = <$fh>;	# skip first line
	while ($line = <$fh>) {
		my @data = split (',', $line);
		last if $data [0] eq ""; # don't remove !!!
		next if any {$_ eq ""} ( $data[4], $data[5] );
#		die "No result for $data[2] v $data[3]\n...in $file\n" if any {$_ eq ""} ( $data[4], $data[5] );
		
		if ($self->{full_data}) {
			push ( @league_games, {
				date => $data [1],
				home_team => $data [2],
				away_team => $data [3],
				home_score => $data [4],
				away_score => $data [5],
				half_time_home => $data [7],
				half_time_away => $data [8],
			});
		} else {
			push ( @league_games, {
				date => $data [1],
				home_team => $data [2],
				away_team => $data [3],
				home_score => $data [4],
				away_score => $data [5],
			});
		}
	}
	close $fh;
	return \@league_games;
}

=pod

=head1 NAME

Football_Data_Model.pm

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