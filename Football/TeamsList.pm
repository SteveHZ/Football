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

=head
Shou;d have a seperate modulr for
opening a TT module (forget this he he)
also goal expect ?? <-- IMPORTANT !!

Comments
Top

The # character is used to indicate comments within a directive. When placed immediately inside the opening directive tag, it causes the entire directive to be ignored.

[%# this entire directive is ignored no
    matter how many lines it wraps onto
%]

In any other position, it causes the remainder of the current line to be treated as a comment.

[% # this is a comment
   theta = 20      # so is this
   rho   = 30      # <aol>me too!</aol>
%]
=cut

1;
