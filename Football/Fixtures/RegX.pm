package Football::Fixtures::RegX;

use Moo;
use namespace::clean;

extends 'MyRegXBase';

sub as_date_month {
	my ($self, $val) = @_;
	$val =~ s/
		\d{4}-(\d{2})-(\d{2})	#	2019-03-14
		/$2\/$1/x;				#	14/03
	return $val;
};
#	$val =~ s/\d{4}-(\d{2})-(\d{2})/$2\/$1/;

sub as_dmy {
	my ($self, $val) = @_;
	$val =~ s/
		\d{2}(\d{2})-(\d{2})-(\d{2})	#	2019-03-14
		/$3\/$2\/$1/x;					#	14/03/19
	return $val;
}
#	$val =~ s/\d{2}(\d{2})-(\d{2})-(\d{2})/$3\/$2\/$1/;

sub remove_postponed {
	my ($self, $dataref) = @_;
	$$dataref =~ s/Match postponed - International call-ups//g;
	$$dataref =~ s/Match postponed - Other//g;
}

sub remove_postponed_chars {
	my ($self, $dataref) = @_;
    $$dataref =~ s/
		[a-z]P	# in between home team and away team, delete both teams
		[A-Z]
	//gx;
# THIS DOESN'T WORK !!
	$$dataref =~ s/
		(?<![S]>) # negative look-behind, do not match SPAL, doesnt need to not match QPR as full name on BBC
		P([A-Z]) # after away team, before start of next home team, keep next home team
	/$1/gx;
}

1;
