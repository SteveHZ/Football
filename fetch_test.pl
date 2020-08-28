use LWP::UserAgent;

my $ua = new LWP::UserAgent;
my $response = $ua->get('https://www.football-data.co.uk/new/$league.csv');
unless ($response->is_success) {
	die $response->status_line;
}
my $content = $response->decoded_content();
if (utf8::is_utf8($content)) {
	binmode STDOUT,':utf8';
} else {
	binmode STDOUT,':raw';
}
print $content;
