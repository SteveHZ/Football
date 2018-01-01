package Football::Spreadsheets::Max_Profit;

use Moo;
use namespace::clean;

has 'filename' => ( is => 'ro' );
with 'Roles::Spreadsheet';

my $path = 'C:/Mine/perl/Football/reports/';
my $filename = $path."max_profit.xlsx";

sub BUILD {
	my $self = shift;
	$self->{filename} = $filename;
}

sub show {
	my ($self, $hash, $sorted) = @_;
	$self->blank_columns ( [ qw(1 3 5 7 9) ] );

	my $worksheet = $self->add_worksheet ("Max Profit");
	do_header ($worksheet, $self->{bold_format});
		
	my $row = 2;
	for my $team (@$sorted) {
		my $row_data = [
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
	my ($worksheet, $format) = @_;
	
	$worksheet->set_column ('A:A', 20);
	$worksheet->set_column ('K:K', 12);
	$worksheet->set_column ($_, 8) for ('C:C','E:E','G:G','I:I');
	$worksheet->set_column ($_, 3) for ('B:B','D:D','F:F','H:H','J:J');

	$worksheet->write ('A1', "Team", $format);
	$worksheet->write ('C1', "Stake", $format);
	$worksheet->write ('E1', "Home", $format);
	$worksheet->write ('G1', "Away", $format);
	$worksheet->write ('I1', "Total", $format);
	$worksheet->write ('K1', "Percentage", $format);
	$worksheet->freeze_panes (2,0);
}

1;