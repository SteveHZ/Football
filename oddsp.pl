#	oddsp.pl 13/03/18

#	Select all games from results frame, right click then View Selection Source
#	Save as text file then enter filename(s) as script argument (without .txt)
 
use strict;
use warnings;

use HTML::Strip;
use Football::Globals qw($short_month_names);
use Euro::Rename qw(check_rename);

my $date = qr/
	(?<date>\d{2})\s
	(?<month>\w+)\s
	(?<year>\d{4})
/x;

my $time = qr/\d{2}:\d{2}/;
my $score = qr/(\d\d?):(\d\d?)/;
my $team = qr/[A-Za-z\& \.]/;
my $odds = qr/\d+\.\d{2}/;

die "Please enter filenames as parameters" unless @ARGV > 0;
for my $file (@ARGV){
	my $in_file = "C:/Mine/perl/Football/data/Euro/scraped/$file.txt";
	my $out_file = "C:/Mine/perl/Football/data/Euro/cleaned/$file.csv";
	open my $fh, "<" , $in_file or die "Can't find $in_file";
	chomp( my $line = <$fh> );
	close $fh;

	my $cleaned = prepare ($line);
	my @games = ();
	my $game_date;

	for my $line (@$cleaned) {
	next if $line =~/postp|award/;
		if ($line =~ /$date/) {
			$game_date = get_date ($line);
		} else {
			my $game = do_game ($game_date, $line);
			print "\n$game->{date} $game->{home_team} v $game->{away_team} ".
					"$game->{home_score}-$game->{away_score} ".
					"$game->{home_odds} $game->{draw_odds} $game->{away_odds}";
			push @games, $game;
		}
	}
	my @ordered = reverse @games;
	write_csv ($out_file, \@ordered);
}

sub prepare {
	my $line = shift;

	my $hs = HTML::Strip->new ( auto_reset => 1 );
	my $cleaned = $hs->parse ($line);

	$cleaned =~ s/($date)/\n$1/g;			#	add new-lines before date
	$cleaned =~ s/$time/\n/g;				#	turn time into new-line
	$cleaned =~ s/\n//;						# 	remove initial newline
	return [ split /\n/, $cleaned ];
}

sub get_date {
	my $line = shift;
	$line =~ /$date/;
	return $+{date}."/".$short_month_names->{ $+{month} }."/".$+{year};
}

sub do_game {
	my ($game_date, $line) = @_;
	my $game = {};
	
	$game->{date} = $game_date;
	( $game->{home_team}, $game->{away_team} ) 	 					= get_teams ($line);
	( $game->{home_score}, $game->{away_score} ) 					= get_score ($line);
	( $game->{home_odds}, $game->{draw_odds}, $game->{away_odds} ) 	= get_odds ($line);
	$game->{result} = get_result ($game->{home_score}, $game->{away_score});
	return $game;
}

sub get_teams {
	my $line = shift;
	$line =~ /\s*($team+) - ($team+) $score/; # ensure no space at end of away team name

	my $home = check_rename ($1);
	my $away = check_rename ($2);
	return ($home, $away);
}

sub get_score {
	my $line = shift;
	$line =~ /$score/;
	return ($1,$2);
}

sub get_odds {
	my $line = shift;
	$line =~ /($odds) ($odds) ($odds)/;
	return ($1,$2,$3);
}

sub get_result {
	my ($home, $away) = @_;
	return 'H' if $home > $away;
	return 'A' if $home < $away;
	return 'D';
}

sub write_csv {
	my ($out_file, $games) = @_;

	open my $fh, ">", $out_file or die "Can't open $out_file";
	print $fh "Div,Date,HomeTeam,AwayTeam,FTHG,FTAG,FTR,HTHG,HTAG,HTR,HS,AS,HST,AST,HFKC,AFKC,HC,AC,HY,AY,HR,AR,B365H,B365D,B365A";
	for my $game (@$games) {
		print $fh 	"\nSH,".$game->{date}.",".$game->{home_team},",". $game->{away_team}.",",
					$game->{home_score}.",". $game->{away_score}.",".$game->{result}.",,,,,,,,,,,,,,,,".
					$game->{home_odds}.",". $game->{draw_odds}.",". $game->{away_odds};
	}
	close $fh;
}

=pod

=head1 NAME

oddsp.pl

=head1 SYNOPSIS

perl oddsp.pl file(s)

=head1 DESCRIPTION

 Select all required games from Odds Portal results frame
 Right click then View Selection Source
 Save as text file
 Enter filename(s) as script argument (without .txt)

=head1 AUTHOR

Steve Hope 2018

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut