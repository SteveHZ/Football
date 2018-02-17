package Football::Spreadsheets::Max_Profit;

use Moo;
use namespace::clean;

use Football::Globals qw(@league_names @euro_lgs);

has 'filename' => ( is => 'ro' );
has 'euro' => ( is => 'ro' );
with 'Roles::Spreadsheet';

my $path = 'C:/Mine/perl/Football/reports/';
my $default_filename = $path."max_profit.xlsx";

sub BUILD {
	my ($self, $args) = @_;
	$self->{filename} = ( exists $args->{filename} )
		? $args->{filename}
		: $default_filename;
	$self->{leagues} = (! $self->{euro} ) ? \@league_names : \@euro_lgs;
}

sub show {
	my ($self, $hash, $sorted) = @_;
	$self->blank_columns ( [ qw(1 3 5 7 9 11) ] );

	my $worksheet = $self->add_worksheet ("Max Profit");
	$self->do_header ($worksheet, $self->{bold_format});
		
	my $row = 2;
	for my $team (@$sorted) {
		my $row_data = [
			{ $self->{leagues}->[ $hash->team($team)->{lg_idx} ], $self->{format} },
			{ $team, $self->{format} },
			{ $hash->team($team)->stake, $self->{currency_format} },
			{ $hash->team($team)->home, $self->{currency_format} },
			{ $hash->team($team)->away,	$self->{currency_format} },
			{ $hash->team($team)->total, $self->{currency_format} },
			{ $hash->team($team)->percent / 100, $self->{percent_format} },
		];
		$self->write_row ($worksheet, $row, $row_data);
		$row ++;
	}
}

sub do_header {
	my ($self, $worksheet, $format) = @_;
	
	$self->set_columns ($worksheet, $self->get_column_sizes ());

	$worksheet->write ('A1', "League", $format);
	$worksheet->write ('C1', "Team", $format);
	$worksheet->write ('E1', "Stake", $format);
	$worksheet->write ('G1', "Home", $format);
	$worksheet->write ('I1', "Away", $format);
	$worksheet->write ('K1', "Total", $format);
	$worksheet->write ('M1', "Percentage", $format);

	$worksheet->autofilter( 'A1:A200' );
	$worksheet->freeze_panes (2,0);
}

sub get_column_sizes {
	my $self = shift;
	
	return {
		"A C" => 20,
		"M" => 12,
		"E G I K" => 8,
		"B D F H J L" => 3,
	};
}

1;