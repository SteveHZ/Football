# 12/07/19
# https://www.1843magazine.com/features/the-daily/how-i-used-maths-to-beat-the-bookies

use MyHeader;
use MyLib qw(var_precision);
use Football::Favourites::Data_Model;
use List::Util qw(any);

my $teams = ['Liverpool', 'Arsenal','Man United', 'Man City', 'Chelsea', 'Tottenham'];
my $path = 'C:/Mine/perl/Football/data/historical/Premier League';
my @years = (2008...2018);
my ($hwins,$awins,$draws,$games) = (0,0,0,0);
my ($hodds, $aodds, $dodds) = (0,0,0);

my $model = Football::Favourites::Data_Model->new ();
for my $year (@years) {
    my $data = $model->update_current ("$path/$year.csv");
#    my $data = $model->update_current ('C:/Mine/perl/Football/data/E0.csv');

    my @data2 = grep {
        games_between ($_->{home_team}, $_->{away_team});
    } @$data;

    for my $game (@data2) {
        say "$game->{home_team} $game->{home_score} $game->{away_team} $game->{away_score}";
        $games++;
        if ($game->{result} eq 'H') { $hwins++; $hodds += $game->{home_odds} }
        elsif ($game->{result} eq 'A') { $awins++; $aodds += $game->{away_odds} }
        elsif ($game->{result} eq 'D') { $draws++; $dodds += $game->{draw_odds} }
    }
}

print "\n";
say "Games : $games";
say "Home wins : $hwins = ".var_sprintf ($hwins, $games)."% Odds = $hodds";
say "Away wins : $awins = ".var_sprintf ($awins, $games)."% Odds = $aodds";
say "Draws : $draws = ".    var_sprintf ($draws, $games)."% Odds = $dodds";

sub games_between ($home, $away) {
    return 1 if
        ( any { $_ eq $home } @$teams )
        &&
        ( any { $_ eq $away } @$teams );
    return 0;
}

sub var_sprintf ($wins, $games){
    return sprintf "%.*f",(var_precision ($wins/$games*100),$wins/$games*100)
}
