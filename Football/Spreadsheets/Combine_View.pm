package Football::Spreadsheets::Combine_View;

use MyClass;

extends qw(
    Football::Spreadsheets::Goal_Expect_View
    Football::Spreadsheets::Max_Profit
);

#   do_goal_expect and do_maxp
#   These two roles do most of the work for this module
with 'Football::Spreadsheets::Combine_Expect';
with 'Football::Spreadsheets::Combine_Maxp';

sub create_sheet {
    my $self = shift;
    my $path = 'C:/Mine/perl/Football/reports/';
    $self->{filename} = $path.'combined.xlsx';
}

=pod

=head1 NAME

Football::Spreadsheets::Combine_View.pm

=head1 SYNOPSIS

use Football::Spreadsheets::Combine_View;

=head1 DESCRIPTION

View for Game_Prediction triad
Most of the work for this module is done by
'Football::Spreadsheets::Combine_Expect'
and 'Football::Spreadsheets::Combine_Maxp'

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
