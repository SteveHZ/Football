package Football::TeamsList;

use MyTemplate;
use Mu;
use namespace::clean;

ro 'leagues'    => (required => 1);
ro 'sorted'     => (required => 1);
ro 'filename'   => (required => 1);

sub create {
    my $self = shift;
    my $tt = MyTemplate->new (filename => $self->{filename});
    my $out_fh = $tt->open_file ();

    $tt->process ('Template/create_new_teams.tt', {
        leagues => $self->{leagues},
        sorted  => $self->{sorted},
    }, $out_fh)
    or die $tt->error;
}

1;
