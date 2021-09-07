my $line1 = "Dover,2,1,H,3.5";
my $line2 = "Dover Athletic,1,3,A,4.4";


sub test {
	$_[0]=~ s/Dover[^\s]/Dover Athletic,/
};


test($line1);
test($line2);

print "\nline 1 = $line1";
print "\nline 2 = $line2";

my $line3 = "Notts Co,2,1,H,3.5";
my $line4 = "Notts County,1,3,A,4.4";

sub test2 {
	$_[0]=~ s/Notts Co[^u]/Notts County,/
};


test2($line3);
test2($line4);

print "\nline 3 = $line3";
print "\nline 4 = $line4";
