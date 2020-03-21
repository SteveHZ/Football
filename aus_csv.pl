
#	aus_csv.pl 16-17/03/20

use strict;
use warnings;

use File::Fetch;

use lib 'C:/Mine/perl/Football';
use Football::Football_Data_Model;
use MyTemplate;
use Football::Globals qw($season);
use Euro::Rename qw(check_rename);

my $in_dir = "C:/Mine/perl/Football/data/Euro/scraped";
my $in_file = "aleague-$season-UTC.csv";

my $out_dir = "C:/Mine/perl/Football/data/Euro";
my $out_file = "AUS.csv";

my $url = "https://fixturedownload.com/download/$in_file";
my $ff = File::Fetch->new (uri => $url);
my $file = $ff->fetch (
    to => "$in_dir",
) or die $ff->error;
print "\nDownloading to $in_dir/$in_file...";

my $data_model = Football::Football_Data_Model->new (
    my_keys => [ qw(round date location aus_home_team aus_away_team score) ],
);
my $games = $data_model->read_csv ("$in_dir/$in_file");

my $dmy = qr/
    \d\d\/          # date
    \d\d\/          # month
    \d\d\d\d        # year
/x;

for my $game (@$games) {
    ( $game->{home_score}, $game->{away_score} ) = split ' - ', $game->{score};
    $game->{date} =~ s/($dmy).*/$1/;
}

my @data = map { {
    league => 'AUS',
    date => $_->{date},
    home_team => check_rename ( $_->{aus_home_team} ),
    away_team => check_rename ( $_->{aus_away_team} ),
    home_score => $_->{home_score},
    away_score => $_->{away_score},
    result => get_result ($_->{home_score}, $_->{away_score}),
} } grep {
    $_->{score} ne ''
} @$games;

print "\nWriting $out_dir/$out_file...";
my $tt = MyTemplate->new (filename => "$out_dir/$out_file");
my $out_fh = $tt->open_file ();

$tt->process ('Template/write_aus.tt', {
    data => \@data
}, $out_fh) or die $tt->error;

print "Done";

sub get_result {
    my ($home, $away) = @_;
    return 'H' if $home > $away;
    return 'A' if $home < $away;
    return 'D';
}

=pod

=head1 NAME

Football/aus_csv.pl

=head1 SYNOPSIS

perl aus_csv.pl

=head1 DESCRIPTION

Stand-alone script to download csv files for A-League games

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
