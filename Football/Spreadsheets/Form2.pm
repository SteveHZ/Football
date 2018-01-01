package Football::Spreadsheets::Form2;

use List::MoreUtils qw (each_arrayref);
use Spreadsheets::Template;
use Moo;
use namespace::clean;

has 'filename' => ( is => 'ro' );
with 'Roles::Spreadsheet';

my $path = 'C:/Mine/perl/Football/reports/';
my $filename = $path."form2.xlsx";
my $template_path = 'C:/Mine/perl/Football/Football/Spreadsheets/';

sub BUILD {
	my $self = shift;
	$self->{filename} = $filename;
	$self->{sheets} = [ "All", "Homes", "Aways", "Last Six" ];
	$self->{lists} = [ "sort_all", "sort_home", "sort_away", "sort_last_six" ];
}

sub show {
	my ($self, $form) = @_;
	$self->blank_columns ( [ qw(1 3 5 7 9) ] );

	my $iterator = each_arrayref ( $self->{sheets}, $self->{lists} );
	while (my ($sheet_name, $list_name) = $iterator->() ) {
		print "\nWriting $sheet_name...";
		my $worksheet = $self->add_worksheet ($sheet_name);
		do_header ($worksheet, $self->{bold_format});
		my $row = 2;
		my $template = Spreadsheets::Template->new (file => $template_path."form.txt");

		for my $team (@{ $form->{$list_name} } ) {
			my $row_data = $template->map ($team);
			$self->template_write_row ($worksheet, $row, $row_data);
			$row ++;
		}
	}
}

sub do_header {
	my ($worksheet, $format) = @_;
	
	$worksheet->set_column ($_, 20) for ('A:A','C:C');
	$worksheet->set_column ($_, 8) for ('E:E','G:G','I:I','K:K');
	$worksheet->set_column ($_, 3) for ('B:B','D:D');
	$worksheet->set_column ($_, 1) for ('F:F','H:H','J:J');

	$worksheet->write ('A1', "League", $format);
	$worksheet->write ('C1', "Team", $format);
	$worksheet->write ('E1', "Total", $format);
	$worksheet->write ('G1', "Homes", $format);
	$worksheet->write ('I1', "Aways", $format);
	$worksheet->write ('K1', "Last Six", $format);

	$worksheet->autofilter( 'A1:A160' );
}

1;