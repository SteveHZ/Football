package Football::Favourites::Model;

use Football::Favourites::Data_Model;
use Football::Globals qw( @league_names @csv_leagues );
use List::MoreUtils qw(each_array);
use File::Copy qw(copy);

use Football::Globals qw($last_season);
use MyLib qw(prompt);

use Moo;
use namespace::clean;
with 'Roles::MyJSON';

has 'hash' => ( is => 'ro' );
has 'json_file' => ( is => 'ro' );

my $path = 'C:/Mine/perl/Football/data';
my $fav_path = 'C:/Mine/perl/Football/data/favourites';

my $uk_file = "$path/favourites_history.json";
my $euro_file = "$path/euro_favourites_history.json";

my $update_favourites = 1;

sub BUILD {
	my ($self, $args) = @_;

	$self->{update} = ($update_favourites) ?
		$args->{update} : $update_favourites;
	$self->{json_file} = $args->{filename} eq 'uk' ?
		$uk_file : $euro_file;
	$self->{history} = (-e $self->{json_file}) ?
		$self->read_json ($self->{json_file}) : [];
}

sub do_favourites {
	my ($self, $year) = @_;

	my $data_model = Football::Favourites::Data_Model->new ();
	my $iterator = each_array ( @league_names, @csv_leagues );

	while ( my ($league, $csv_league) = $iterator->() ) {
		my $file_from = "$path/$csv_league.csv";
		my $file_to = "$fav_path/$league/$year.csv";

		my $data = $data_model->update_current ($file_from, $year);
		$data_model->write_current ($file_to, $data);
		$self->update ($league, $year, $data);
	}
	return {
		data => $self->hash (),
		history => $self->history ($year),
		leagues => \@league_names,
		year => $year,
	};
}

sub setup {
	return {
		stake => 0,
		fav_winnings => 0,
		under_winnings => 0,
		draw_winnings => 0,
	};
}

sub history {
	my ($self, $year) = @_;
	$self->check_history ($year);
	
	if ($self->{update}) {
		push $self->{history}->@*, $self->{hash};
		$self->write_json ($self->{json_file}, $self->{history});
	}
	return $self->{history};
}

sub update {
	my ($self, $league, $year, $results) = @_;
	$self->{hash}->{$league}->{$year} = $self->setup ();
	my $hashref = $self->{hash}->{$league}->{$year};

	for my $game (@$results) {
		if ($game->{home_odds}) {
			$hashref->{stake} ++;
			if ($game->{result} eq 'D') {
				$hashref->{draw_winnings} += $game->{draw_odds};
			} elsif ($game->{home_odds} > $game->{away_odds}) {
				if ($game->{result} eq 'H'){
					$hashref->{under_winnings} += $game->{home_odds};
				} else {
					$hashref->{fav_winnings} += $game->{away_odds};
				}
			} else {
				if ($game->{result} eq 'A'){
					$hashref->{under_winnings} += $game->{away_odds};
				} else {
					$hashref->{fav_winnings} += $game->{home_odds};
				}
			}
		}
	}
}

=begin comment

Written 07-08/09/21 to hopefully avoid having loads of errors at the start of a season because $year has been updated in Football::Globals
but data/favourites_history.json still has references to the previous season ,which in the past have been manually copied to a backup file,
though only after having to investigate why the errors were occuring AGAIN !!!.
This section should copy last season's data to a back-up file then start again from an empty $self->{history} array.
This appears to work in testing, but would recommend manual backups first for 2022-23 season, then let it run through
to check it works correctly. 
Worked OK August 2022
=end comment
=cut

sub check_history {
	my ($self, $year) = @_;

	unless (defined $self->{history}->@[0]->{'Premier League'}->{$year}) {
#		print "\nIMPORTANT : 08/09/21 - This APPEARS to work correctly but would recommend choosing NO first and creating manual back-ups";
#		print "\nJust to be on the safe side - see Football::Favourites::Model::check_history";
		my $yn = prompt ("\nDelete data for last season from $self->{json_file} and create back-up for $last_season ? (y/n to quit) ", "> ");
		if ($yn eq 'n') {
			die "\nPlease delete data manually from history file : $self->{json_file}\n";
		} else {
			$self->do_backup_file ($last_season);
			$self->{history} = [];
		}
	}
}

sub do_backup_file {
	my ($self, $backup_season) = @_;

	my $backup_file = $self->get_backup_filename ($backup_season);
	print "\nWriting $backup_file...";
	unlink $backup_file if -e $backup_file;
	copy ($self->{json_file}, $backup_file);
}

sub get_backup_filename {
	my ($self, $backup_season) = @_;

	my ($filename, $ext) = split '\.', $self->{json_file};
	return "$filename $backup_season\.json";
}

=pod

=head1 NAME

Football::Favourites_Model.pm

=head1 SYNOPSIS

Model for Favourites triad

=head1 DESCRIPTION

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
