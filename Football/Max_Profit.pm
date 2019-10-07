package Football::Max_Profit;

use MyHeader;

use Football::Model;
use Euro::Model;
use Summer::Model;

use Football::Favourites::Data_Model;
use Summer::Summer_Data_Model;
use Football::Globals qw( @csv_leagues @euro_csv_lgs @summer_csv_leagues );
use Football::Globals qw( @league_names @euro_lgs @summer_leagues );

use Football::Team_Hash;
use MyJSON qw(read_json);

use List::MoreUtils qw(each_arrayref);
use Mu;
use namespace::clean;

ro 'team_hash', default => sub { {} };

sub BUILD {
    my ($self, $args) = @_;
    my $region = $args->{region};
    my @funcs = (
        sub { $self->get_uk_data () },      # uk : region 0 see max_profit.pl
        sub { $self->get_euro_data () },    # euro : region 1
        sub { $self->get_summer_data () },  # summer : region 2
    );
    $self->{data} = $funcs[$region]->();
    $self->{team_hash} = Football::Team_Hash->new (
    	leagues		=> $self->{data}->{league_names},
        fixtures    => $self->{data}->{model}->get_fixtures (),
    );
}

sub calc {
    my $self = shift;
    my $data = $self->{data};
    my $team_hash = $self->{team_hash};

    my $iterator = each_arrayref ($data->{league_names}, $data->{leagues}, $data->{index});
    while (my ($league_name, $csv_league, $lg_idx) = $iterator->()) {
    	my $file = $data->{in_path}.$csv_league.".csv";
    	my $results = $data->{read_func}->( undef, $file ); # no $self

    	$team_hash->add_teams ($results, $data->{teams}->{$league_name}, $lg_idx);
        $self->do_straight_win ($results);
    }
    return $team_hash->sort ();
}

sub do_straight_win {
    my ($self, $results) = @_;
    my $team_hash = $self->{team_hash};

	for my $game (@$results) {
#		DEVELOPMENT { print "\n$game->{home_team} v $game->{away_team}"; }
		if ( $game->{home_odds} && $game->{away_odds} ) {
			$team_hash->place_stakes ($game);
			if ($game->{result} eq 'H') {
				$team_hash->home_win ( $game->{home_team}, $game->{home_odds} );
			} elsif ($game->{result} eq 'A') {
				$team_hash->away_win ( $game->{away_team}, $game->{away_odds} );
			}
		}
	}
}

sub get_filename {
    my $self = shift;
    return $self->{data}->{out_path}.'max_profit.xlsx';
}

sub get_datafile_name {
    my $self = shift;
    return 'C:/Mine/perl/Football/data/combine data/maxp '.$self->{data}->{model_type}.'.json';
}

sub get_combine_file_data {
    my ($self, $sorted) = @_;
    return $self->{team_hash}->get_combine_file_data ($sorted);
}

sub get_uk_data {
	return {
		model		=> Football::Model->new (),
		model_type	=> 'uk',
		read_func 	=> \&Football::Favourites::Data_Model::update_current,
		in_path 	=> 'C:/Mine/perl/Football/data/',
		out_path 	=> 'C:/Mine/perl/Football/reports/',
		leagues 	=> \@csv_leagues,
		league_names=> \@league_names,
		index 		=> [ 0...$#csv_leagues ],
		teams		=> read_json ('C:/Mine/perl/Football/data/teams.json'),
	}
}

sub get_euro_data {
	return {
		model		=> Euro::Model->new (),
		model_type	=> 'euro',
		read_func 	=> \&Football::Favourites::Data_Model::update_current,
		in_path 	=> 'C:/Mine/perl/Football/data/Euro/',
		out_path 	=> 'C:/Mine/perl/Football/reports/Euro/',
		leagues 	=> \@euro_csv_lgs,
		league_names=> \@euro_lgs,
		index 		=> [ 0...$#euro_csv_lgs ],
		teams		=> read_json ('C:/Mine/perl/Football/data/Euro/teams.json'),
	}
}

sub get_summer_data {
	return {
		model		=> Summer::Model->new (),
		model_type	=> 'summer',
		read_func 	=> \&Summer::Summer_Data_Model::read_csv,
		in_path 	=> 'C:/Mine/perl/Football/data/Summer/',
		out_path 	=> 'C:/Mine/perl/Football/reports/Summer/',
		leagues 	=> \@summer_csv_leagues,
		league_names=> \@summer_leagues,
		index 		=> [ 0...$#summer_csv_leagues ],
		teams		=> read_json ('C:/Mine/perl/Football/data/Summer/teams.json'),
	}
}

1;
