#   fantasy.pl 01/12/18

use MyHeader;
use MyJSON qw(read_json);
use Savings qw(fmt);
use Football::Spreadsheets::Fantasy;

use File::Fetch;
use File::Copy qw(move);
use utf8;

my $json_file = "C:/Mine/perl/Football/data/fantasy.json";
my $teams_file = "C:/Mine/perl/Football/data/teams.json";

my @players = ();
my @positions = qw(Goalkeeper Defender Midfield Forward);
my $price_format = "%.1fm";
#my $price_format = chr(156)."%.1fm";

#if (defined $ARGV [0]) {
#    update ($json_file) if $ARGV[0] eq '-u';
#}

unless (defined $ARGV [0] && $ARGV [0] eq '-n') {
	update ($json_file);
}

my $data = read_json ($json_file);
my $teams = read_json ($teams_file)->{'Premier League'};

for my $row ($data->{elements}) {
    for my $player (@$row) {
#		error in Fantasy Football files 2020 (Leeds and Leicester)
       if    ( $player->{team} == 10 )  { $player->{team} = 11; }
       elsif ( $player->{team} == 11 )  { $player->{team} = 10; }

        push @players, {
            name => "$player->{first_name} $player->{second_name}",
            team => @$teams [ $player->{team} - 1 ],
            total_points => $player->{total_points},
			points_per_game => $player->{points_per_game},
			minutes => $player->{minutes},
			position => $positions [ $player->{element_type} -1 ],
            selected_by => $player->{selected_by_percent},
            price => fmt ( $player->{now_cost} / 10, $price_format ),
			news => $player->{news},
			ict_index_rank_type => $player->{ict_index_rank_type},
			ict_index_rank => $player->{ict_index_rank},
			value => sprintf "%.2f",( $player->{total_points} / $player->{now_cost} * 100 ), 
        };
    }
}

my $sorted = {};
for my $position (@positions) {
    say "\n".uc $position." :";
    $sorted->{$position} = sort_by_position (\@players, $position);
    say "$_->{name} $_->{team} $_->{position} $_->{price} $_->{total_points} $_->{points_per_game} $_->{minutes} $_->{news} $_->{value}"
	   for $sorted->{$position}->@*;
}

my $view = Football::Spreadsheets::Fantasy->new (sheets => \@positions);
$view->write ($sorted);

sub sort_by_position {
    my ($players, $position) = @_;
    return [
        sort { $b->{total_points} <=> $a->{total_points} or $b->{minutes} <=> $a->{minutes} }
#		sort { $b->{value} <=> $a->{value} or $b->{total_points} <=> $a->{total_points} }
        grep { $_->{points_per_game} >= 3 }
        grep { $_->{position} eq $position }
        @$players
    ];
}

sub update {
    my $json_file = shift;
    my $dir = "C:/Mine/perl/Football/data";
    my $url = "https://fantasy.premierleague.com/api/bootstrap-static/";
#	previously https://fantasy.premierleague.com/drf/bootstrap-static

    say "\nDownloading $json_file...";
    my $ff = File::Fetch->new (uri => $url);
    my $download = $ff->fetch (to => $dir) or die $ff->error;
    move $download, $json_file;
}
