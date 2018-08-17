subtest
my obj = gd->new();
my @gds = (5,-14,106,-112);
for my $gd(@gds) {
like ($_,qr/\d{1,}/) for @{$obj->fetch_array ($gd)};
}