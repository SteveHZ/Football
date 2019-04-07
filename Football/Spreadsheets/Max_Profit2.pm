package Football::Spreadsheets::Max_Profit2;

use v5.10;
use Football::Globals qw(@league_names @euro_lgs @summer_leagues);
use MyLib qw(wordcase);

use Mu;
use namespace::clean;

ro 'filename';
ro 'euro';
with 'Roles::Spreadsheet';

my $path = 'C:/Mine/perl/Football/reports/';
my $default_filename = $path."max_profit2.xlsx";
my @all_leagues = ( \@league_names, \@euro_lgs, \@summer_leagues );

sub BUILD {
	my ($self, $args) = @_;
	$self->{filename} = ( exists $args->{filename} )
		? $args->{filename}
		: $default_filename;
	$self->{euro} //= 0; # work-around to construct Combine_View
	$self->{leagues} = $all_leagues [ $self->{euro} ];
	$self->{sheetnames} = [ 'totals', 'all homes', 'all aways', 'homes', 'aways' ];
	$self->{dispatch} = {
		'totals'	=> sub { my $self = shift; $self->get_totals (@_) },
		'all homes'	=> sub { my $self = shift; $self->get_homes (@_) },
		'all aways'	=> sub { my $self = shift; $self->get_aways (@_) },
		'homes'		=> sub { my $self = shift; $self->get_homes (@_) },
		'aways'		=> sub { my $self = shift; $self->get_aways (@_) },
	};
}

sub show {
	my ($self, $hash, $sorted) = @_;
	$self->blank_columns ( [ qw(1 3 5 7 9 11 13) ] );

	for my $sheet (@{ $self->{sheetnames} }) {
		my $worksheet = $self->add_worksheet (wordcase $sheet);
		$self->do_header ($worksheet, $self->{bold_format});

		my $row = 2;
		for my $team (@{ $sorted->{$sheet} }) {
			my $row_data = $self->{dispatch}->{$sheet}->($self, $hash, $team);
			$self->write_row ($worksheet, $row, $row_data);
			$row ++;
		}
	}
}

sub do_header {
	my ($self, $worksheet, $format) = @_;

	$self->set_columns ($worksheet, $self->get_maxp_columns ());

	$worksheet->write ('A1', 'League', $format);
	$worksheet->write ('C1', 'Team', $format);
	$worksheet->write ('E1', 'Stake', $format);
	$worksheet->write ('G1', 'Home', $format);
	$worksheet->write ('I1', 'Away', $format);
	$worksheet->write ('K1', 'Balance', $format);
	$worksheet->write ('M1', 'Percentage', $format);
	$worksheet->write ('O1', 'Win Rate', $format);

	$worksheet->autofilter( 'A1:A200' );
	$worksheet->freeze_panes (2,0);
}

#	called as arguments to $self->{dispatch}

sub get_totals {
	my ($self, $hash, $team) = @_;
	return [
		{ $self->{leagues}->[ $hash->team($team)->{lg_idx} ], $self->{format} },
		{ $team, $self->{format} },
		{ $hash->team($team)->total_stake, $self->{currency_format} },
		{ $hash->team($team)->home, $self->{currency_format} },
		{ $hash->team($team)->away,	$self->{currency_format} },
		{ $hash->team($team)->balance, $self->{currency_format} },
		{ $hash->team($team)->percent, $self->{percent_format} },
		{ $hash->team($team)->total_win_rate, $self->{percent_format} },
	];
}

sub get_homes {
	my ($self, $hash, $team) = @_;
	return [
		{ $self->{leagues}->[ $hash->team($team)->{lg_idx} ], $self->{format} },
		{ $team, $self->{format} },
		{ $hash->team($team)->home_stake, $self->{currency_format} },
		{ $hash->team($team)->home, $self->{currency_format} },
		{ $hash->team($team)->away,	$self->{currency_format} },
		{ $hash->team($team)->balance, $self->{currency_format} },
		{ $hash->team($team)->home_percent, $self->{percent_format} },
		{ $hash->team($team)->home_win_rate, $self->{percent_format} },
	];
}

sub get_aways {
	my ($self, $hash, $team) = @_;
	return [
		{ $self->{leagues}->[ $hash->team($team)->{lg_idx} ], $self->{format} },
		{ $team, $self->{format} },
		{ $hash->team($team)->away_stake, $self->{currency_format} },
		{ $hash->team($team)->home, $self->{currency_format} },
		{ $hash->team($team)->away,	$self->{currency_format} },
		{ $hash->team($team)->balance, $self->{currency_format} },
		{ $hash->team($team)->away_percent, $self->{percent_format} },
		{ $hash->team($team)->away_win_rate, $self->{percent_format} },
	];
}

sub get_maxp_columns {
	my $self = shift;

	return {
		"A C" => 20,
		"M" => 12,
		"E G I K O" => 8,
		"B D F H J L N" => 3,
	};
}

1;
