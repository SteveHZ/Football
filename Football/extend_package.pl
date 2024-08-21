# extend_package.pl 16/07/24
# https://blogs.perl.org/users/bruce_gray/2024/07/twc-277-strength-uncombined.html


#use strict;
#use warnings;
#use v5.38;

use MyHeader;
use Football::Fetch_Amend;

package Football::Fetch_Amend {
	sub hello ($self, $name) {
		say "Hello $name";
	}
}

my $fa = Football::Fetch_Amend->new ();
$fa->hello ("Steve !!");