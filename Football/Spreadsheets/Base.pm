package Football::Spreadsheets::Base;

#	Football::Spreadsheets::Base.pm 07/02/16

use strict;
use warnings;

use Excel::Writer::XLSX;

sub new {
	my ($class, $xlsx_file) = @_;
	my $self = {};

	$self->{workbook} = Excel::Writer::XLSX->new ($xlsx_file)
		or die "Problems creating new Excel file : $!";

	$self->{format} = $self->{workbook}->add_format (
		bg_color => '#FFC7CE',
		color => 'blue',
		align => 'center',
		num_format => '#0',
	);
	$self->{bold_format} = $self->{workbook}->add_format (
		bg_color => '#FFC7CE',
		color => 'black',
		align => 'center',
		num_format => '#0',
		bold => 'true',
		border => 1,
	);
    bless $self, $class;
    return $self;
}

1;