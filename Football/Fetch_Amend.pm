package Football::Fetch_Amend;

use MyLib qw(read_file write_file);
use File::Copy qw(copy);

use Moo;
use namespace::clean;

sub BUILD {
	my $self = shift;
	$self-> {paths} = {
		'uk'	 => 'C:/Mine/perl/Football/data',
		'euro' 	 => 'C:/Mine/perl/Football/data/Euro',
		'summer' => 'C:/Mine/perl/Football/data/Summer',
	};
}

sub get_uk_hash {
	return {
		'E0' => [
			sub { $_[0] =~ s/Man United/Man Utd/g },
			sub { $_[0] =~ s/Nott'm Forest/Notts Forest/g },
			sub { $_[0] =~ s/Sheffield United/Sheff Utd/g },
		],
		'E1' => [
			sub { $_[0] =~ s/Sheffield Weds/Sheff Wed/g },
			sub { $_[0] =~ s/Middlesbrough/Middlesboro/g },
		],
		'E2' => [
			sub { $_[0] =~ s/Fleetwood Town/Fleetwood/g },
		],
		'E3' => [
			sub { $_[0] =~ s/AFC Wimbledon/Wimbledon/g },
			sub { $_[0] =~ s/Crawley Town/Crawley/g },
			sub { $_[0] =~ s/Milton.*Dons/MK Dons/g },
			sub { $_[0] =~ s/Newport County/Newport/g },
		],
		'SC1' => [
			sub { $_[0] =~ s/Dundee United/Dundee Utd/g },
			sub { $_[0] =~ s/Inverness C/Inverness/g },
			sub { $_[0] =~ s/Airdrie Utd/Airdrie/g },
		],
		'SC2' => [
			sub { $_[0] =~ s/Edinburgh City/Edinburgh/g },
		]
	};
}

sub get_euro_hash {
	return {
		'D1' => [
			sub { $_[0] =~ s/M'gladbach/Mgladbach/g },
			sub { $_[0] =~ s/Ein Frankfurt/Frankfurt/g },
#			sub { $_[0] =~ s/Schalke 04/Schalke/g },
		],
		'F1' => [
			sub { $_[0] =~ s/Paris SG/PSG/g },
		],
	};
}

sub get_summer_hash {
	return {
		'SWE' => [
			sub { $_[0] =~ s/Varberg,/Varbergs,/g }, # errors in datafile 2022
			sub { $_[0] =~ s/Brommapojkarna/Brommapj/g },
			sub { $_[0] =~ s/Vasteras SK/Vasteras/g },
		],
		'MLS' => [
			sub { $_[0] =~ s/Atlanta United/Atlanta Utd/g },
			sub { $_[0] =~ s/St. Louis/St Louis/g },
			sub { $_[0] =~ s/Toronto FC/Toronto/g },
			sub { $_[0] =~ s/Austin FC/Austin/g },
			sub { $_[0] =~ s/Los Angeles FC/Los Angeles/g },
#			sub { $_[0] =~ s/FC Dallas/Dallas/g },
		],
		'FIN' => [
			sub { $_[0] =~ s/Ekenas/EIF/g },
		],
	};
}

sub amend_uk {
	my $self = shift;
	$self->amend_teams (get_uk_hash (), $self->{paths}->{uk} );
}

sub amend_euro {
	my $self = shift;
	$self->amend_teams (get_euro_hash (), $self->{paths}->{euro} );
}

sub amend_summer {
	my $self = shift;
	$self->amend_teams (get_summer_hash (), $self->{paths}->{summer} );
}

sub amend_teams {
	my ($self, $replace_hash, $path) = @_;

	while (my ($league, $teams_rx) = each $replace_hash->%*) {
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

sub amend_array {
	my ($self, $lines, $rx_array) = @_;
	for my $line (@$lines) {
		for my $rx ($rx_array->@*) {
			$rx->($line);
		}
	}
}

=begin comment
# errors in datafiles

		'EC' => [
# "Lynn," needed because of 29/01/22 Boreham Wood v Kings Lynn REF - S Yianni - regex is greedy !!
			sub { $_[0] =~ s/King.*Lynn,/Kings Lynn,/g },

			sub { $_[0] =~ s/Dag & Red/Dag and Red/g }, # errors in EC data file 2021-22
			sub { $_[0] =~ s/FC Halifax/Halifax/g },
			sub { $_[0] =~ s/Notts Co(?!unty),/Notts County,/g },
			sub { $_[0] =~ s/Dover(?! A),/Dover Athletic,/g },
		],
		'EC' => [
			sub { $_[0] =~ s/York City/York/g }, # errors in datafile 2022
		],

=end comment
=cut

=pod

=head1 NAME

 Fetch_Amend.pm

=head1 SYNOPSIS

 Used by fetch.pl

=head1 DESCRIPTION

 Use functions amend_uk, amend_euro or amend_summer
 to amend Football Data team names for the respective files.

=head1 AUTHOR

 Steve Hope

=head1 LICENSE

 This library is free software. You can redistribute it and/or modify
 it under the same terms as Perl itself.

=cut

1;
