package Football::Fixtures_Globals;

use strict;
use warnings;

use Exporter 'import';

use vars qw (@EXPORT_OK %EXPORT_TAGS);

our @EXPORT = qw(
	%football_rename
	%rugby_rename
	%football_fixtures_leagues
	%rugby_fixtures_leagues
);

@EXPORT_OK  = qw( football_rename rugby_rename);
%EXPORT_TAGS = (all => [ @EXPORT, @EXPORT_OK ]);

sub new { return bless {}, shift; }

our %football_rename = ();
our %rugby_rename = ();
our %football_fixtures_leagues = ();
our %rugby_fixtures_leagues = ();

my @datarefs = (
	{ hashref => \%football_rename, end_token => 'END_FOOTBALL_TEAMS' },
	{ hashref => \%rugby_rename, end_token => 'END_RUGBY_TEAMS' },
	{ hashref => \%football_fixtures_leagues, end_token => 'END_FOOTBALL_LEAGUES' },
	{ hashref => \%rugby_fixtures_leagues, end_token => 'END_RUGBY_LEAGUES' },
);

for my $dataref (@datarefs) {
	while (my $line = <DATA>) {
		chomp $line;
		next if $line eq "" or $line =~ /^#/;
		last if $line eq $dataref->{end_token};
		my ($key, $val) = split ',', $line;
		$dataref->{hashref}->{$key} = $val;
	}
}
close DATA;

sub football_rename {
	my $name = shift;
	return unless defined $name;
	return defined $football_rename{ $name }
		? $football_rename{ $name } : $name
}


sub rugby_rename {
	my $name = shift;
	return unless defined $name;
	return defined $rugby_rename{ $name }
		? $rugby_rename{ $name } : $name
}

__DATA__
#	Irish
St Patrick's Athletic,St Patricks

#	American
D.C. United,DC United
Minnesota United FC,Minnesota
Atlanta United FC,Atlanta United
New York City FC,New York City
Seattle Sounders FC,Seattle Sounders
Vancouver Whitecaps FC,Vancouver Whitecaps
Los Angeles Football Club,Los Angeles FC

#	English
Brighton & Hove Albion,Brighton
Manchester City,Man City
Manchester United,Man United
Leicester City,Leicester
Swansea City,Swansea
Newcastle United,Newcastle
Huddersfield Town,Huddersfield
AFC Bournemouth,Bournemouth
West Bromwich Albion,West Brom
West Ham United,West Ham
Stoke City,Stoke
Tottenham Hotspur,Tottenham
Birmingham City,Birmingham
Ipswich Town,Ipswich
Nottingham Forest,Nott'm Forest
Hull City,Hull
Cardiff City,Cardiff
Burton Albion,Burton
Leeds United,Leeds
Bolton Wanderers,Bolton
Norwich City,Norwich
Sheffield Wednesday,Sheffield Weds
Wolverhampton Wanderers,Wolves
Queens Park Rangers,QPR
Derby County,Derby
Oxford United,Oxford
Scunthorpe United,Scunthorpe
Wigan Athletic,Wigan
Oldham Athletic,Oldham
Doncaster Rovers,Doncaster
Bristol Rovers,Bristol Rvs
Northampton Town,Northampton
Charlton Athletic,Charlton
Plymouth Argyle,Plymouth
Southend United,Southend
Shrewsbury Town,Shrewsbury
Rotherham United,Rotherham
Peterborough United,Peterboro
Blackburn Rovers,Blackburn
Bradford City,Bradford
Crewe Alexandra,Crewe
Cambridge United,Cambridge
Cheltenham Town,Cheltenham
Carlisle United,Carlisle
Colchester United,Colchester
Luton Town,Luton
Grimsby Town,Grimsby
Lincoln City,Lincoln
Exeter City,Exeter
Mansfield Town,Mansfield
Accrington Stanley,Accrington
Coventry City,Coventry
Wycombe Wanderers,Wycombe
Swindon Town,Swindon
AFC Fylde,Fylde
FC Halifax Town,Halifax
Dagenham & Redbridge,Dag and Red
Maidstone United,Maidstone
Hartlepool United,Hartlepool
Harrogate Town,Harrogate
Solihull Moors,Solihull
Aldershot Town,Aldershot
Macclesfield Town,Macclesfield
Tranmere Rovers,Tranmere
Ebbsfleet United,Ebbsfleet
Maidenhead United,Maidenhead
Sutton United,Sutton
Salford City,Salford

#	Scottish
Partick Thistle,Partick
Hamilton Academical,Hamilton
Heart of Midlothian,Hearts
Queen of the South,Queen of Sth
Brechin City,Brechin
Inverness Caledonian Thistle,Inverness C
Greenock Morton,Morton
Alloa Athletic,Alloa
Ayr United,Ayr
Queen's Park,Queens Park
Airdrieonians,Airdrie Utd
Raith Rovers,Raith Rvs
Albion Rovers,Albion Rvs
Forfar Athletic,Forfar
Berwick Rangers,Berwick
Elgin City,Elgin
Stirling Albion,Stirling
END_FOOTBALL_TEAMS

#	Rugby League
Castleford,Castleford Tigers
Wakefield,Wakefield Trinity
Wigan,Wigan Warriors
Leeds,Leeds Rhinos
Hudd'sfld,Huddersfield
Salford,Salford Red Devils
Warrington,Warrington Wolves
Catalans,Catalans Dragons
Widnes,Widnes Vikings
Dewsbury,Dewsbury Rams
Rochdale,Rochdale Hornets
Toulouse,Toulouse Olympique
London,London Broncos
Featherstone,Featherstone Rovers
Leigh,Leigh Centurions
Toronto,Toronto Wolfpack
Barrow,Barrow Raiders
York,York City Knights
Coventry,Coventry Bears
Hunslet,Hunslet Hawks
Keighley,Keighley Cougars
Crusaders,North Wales Crusaders
Raiders,West Wales Raiders
Workington,Workington Town
Newcastle,Newcastle Thunder
Bradford,Bradford Bulls
END_RUGBY_TEAMS

Welsh Premier League,WL
Irish Premiership,NI
Premier League,E0
Championship,EC
League One,E2
League Two,E3
National League,EC
Scottish Premiership,SC0
Scottish Championship,SC1
Scottish League One,SC2
Scottish League Two,SC3
Spanish La Liga,SP1
Italian Serie A,I1
Irish Premier Division,ROI
Norwegian Eliteserien,NRW
Swedish Allsvenskan,SWD
Finnish Veikkausliiga,FN
United States Major League Soccer,MLS

International,X
World,X
Euro,X
Women's,X
Friendl,X
Group,X
Round,X
Russian Premier League,X
Swiss Super League,X
Brazilian,X
Danish,X
END_FOOTBALL_LEAGUES

Super League,SL
Championship,CH
League 1,L1
Qualifiers,M8
Shield,SH
END_RUGBY_LEAGUES
=pod

=head1 NAME

Football::Fixture_Globals.pm

=head1 SYNOPSIS

Used by predict.pl

=head1 DESCRIPTION

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;