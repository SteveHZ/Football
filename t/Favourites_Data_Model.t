#	Favourites_Data_Model.t 14/09/16

use Test2::V0;
plan 2;

use lib "C:/Mine/perl/Football";
use Football::Favourites::Data_Model;

#my $file = 'test data/E0.csv';
#my $file2 = 'test data/EC.csv';
my $data_model = Football::Favourites::Data_Model->new ();

subtest 'constructor' => sub {
	plan 1;
	isa_ok ($data_model, ['Football::Favourites::Data_Model'], '$data_model');
};

subtest 'update current' => sub {
#	tests get_odds_cols in Odds_Cols role by testing
#	two files with odds in different columns
	plan 2;
	subtest 'before 2019' => sub {
		plan 2;

		my $year = 2017;
		my $file1 = "test data/E0 $year.csv";
		my $file2 = "test data/EC $year.csv";

		subtest 'Premier League' => sub {
			plan 5;
			my $games = $data_model->update_current ($file1, $year);
			is (@$games[0]->{home_odds} , 1.53, 'home odds ok');
			is (@$games[0]->{away_odds} , 6.5,  'away odds ok');
			is (@$games[0]->{draw_odds} , 4.5,  'draw odds ok');
			is (@$games[0]->{over_odds} , 1.61, 'over odds ok');
			is (@$games[0]->{under_odds}, 2.32, 'under odds ok');
		};

		subtest 'Conference' => sub {
			plan 5;
			my $games = $data_model->update_current ($file2, $year);
			is (@$games[0]->{home_odds} , 2.9,  'home odds ok');
			is (@$games[0]->{away_odds} , 2.38, 'away odds ok');
			is (@$games[0]->{draw_odds} , 3.4,  'draw odds ok');
			is (@$games[0]->{over_odds} , 1.86, 'over odds ok');
			is (@$games[0]->{under_odds}, 1.88, 'under odds ok');
		};
	};
	subtest 'since 2019' => sub {
		plan 2;

		my $year = 2021;
		my $file1 = "test data/E0 $year.csv";
		my $file2 = "test data/EC $year.csv";

		subtest 'Premier League' => sub {
			plan 5;
			my $games = $data_model->update_current ($file1, $year);
			is (@$games[0]->{home_odds} , 4,    'home odds ok');
			is (@$games[0]->{away_odds} , 1.95, 'away odds ok');
			is (@$games[0]->{draw_odds} , 3.4,  'draw odds ok');
			is (@$games[0]->{over_odds} , 2.1,  'over odds ok');
			is (@$games[0]->{under_odds}, 1.72, 'under odds ok');
		};

		subtest 'Conference' => sub {
			plan 5;
			my $games = $data_model->update_current ($file2, $year);
			is (@$games[0]->{home_odds} , 3.3,  'home odds ok');
			is (@$games[0]->{away_odds} , 2,    'away odds ok');
			is (@$games[0]->{draw_odds} , 3.5,  'draw odds ok');
			is (@$games[0]->{over_odds} , 1.75, 'over odds ok');
			is (@$games[0]->{under_odds}, 2.05, 'under odds ok');
		};
	};
};
