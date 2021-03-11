package Football::Fetch_Amend;

use MyLib qw(read_file write_file);
use File::Copy qw(copy);

use Moo;
use namespace::clean;

sub get_uk_hash {
	return {
		'E0' => [
			sub { $_[0] =~ s/Man United/Man Utd/g },
			sub { $_[0] =~ s/Sheffield United/Sheff Utd/g },
		],
		'E1' => [
			sub { $_[0] =~ s/Sheffield Weds/Sheff Wed/g },
			sub { $_[0] =~ s/Nott'm Forest/Notts Forest/g },
		],
		'E2' => [
			sub { $_[0] =~ s/Milton.*Dons/MK Dons/g },
		],
		'EC' => [
			sub { $_[0] =~ s/Kin.*nn/Kings Lynn/g },
		],
	};
}

sub get_euro_hash { return {}; }
sub get_summer_hash { return {}; }

sub amend_uk {
	my $self = shift;
	my $path = "C:/Mine/perl/Football/data";
	$self->amend_teams (get_uk_hash (), $path);
}

sub amend_euro {
	my $self = shift;
	my $path = "C:/Mine/perl/Football/data/Euro";
	$self->amend_teams (get_euro_hash (), $path);
}

sub amend_summer {
	my $self = shift;
	my $path = "C:/Mine/perl/Football/data/Summer";
	$self->amend_teams (get_summer_hash (), $path);
}

sub amend_array {
	my ($self, $lines, $rx_array) = @_;
	for my $line (@$lines) {
		for my $rx ($rx_array->@*) {
			$rx->($line);
		}
	}
}

sub amend_teams {
	my ($self, $replace, $path) = @_;

	while (my ($league, $teams_rx) = each $replace->%*) {
		my $file = "$path/$league.csv";
		my $temp_file = "$path/$league-temp.csv";

		print "\nRewriting $file...";
		copy $file, $temp_file;
		my $lines = read_file ($temp_file);
		$self->amend_array ($lines, $teams_rx);

		write_file ($file, $lines);
		unlink $temp_file;
	}
}

=pod

=head1 NAME

Fetch_Amend.pm

=head1 SYNOPSIS

Used by fetch.pl

=head1 DESCRIPTION

Use functions amend_uk, amend_euro or amend_summer
to amend team names for the respective files.

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
