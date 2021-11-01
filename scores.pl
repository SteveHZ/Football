#	scores.pl 18-19/10/21

use strict;
use warnings;

use Football::Football_Data_Model;
use Football::Globals qw(@csv_leagues);

my $games = 0;
my $hash = {};
my $data_model = Football::Football_Data_Model->new();

for my $league (@csv_leagues) {
	my $data = $data_model->read_csv ("C:/Mine/perl/Football/data/$league.csv");

	for my $game (@$data) {
		$games ++;
		my $result = "$game->{home_score}-$game->{away_score}";
		$hash->{$result} ++;
	}
}

# Example of $hash at this point :
# { "1-1" => 6, "1-0" => 6, "2-0" => 4, "2-1" => 4, "3-1" => 3 }

my $reverse_hash = {};
for my $score (keys %$hash) {
	push $reverse_hash->{$hash->{$score}}->@*, $score;
}

# Example of $reverse_hash at this point using $hash as above :
# { 6 => ["1-1", "1-0"],
#	4 => ["2-0", "2-1"],
#	3 => ["3-1"]
# }

my @sorted = sort {$b <=> $a} keys $reverse_hash->%*;
for my $key (@sorted) {
	for my $score ($reverse_hash->{$key}->@*) {
		my $percent = sprintf "%.2f", $key / $games * 100;
		print "\n$score => $key => $percent \%";
	}
}

=pod

=head1 NAME

 scores.pl

=head1 SYNOPSIS

 perl scores.pl
  
=head1 DESCRIPTION
	
 Calculates the frequency of all scores in all British leagues
 
=head1 AUTHOR

 Steve Hope 2021

=head1 LICENSE

 This library is free software. You can redistribute it and/or modify
 it under the same terms as Perl itself.

=cut
