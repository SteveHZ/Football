package Football::Fixtures_Globals;

#	Creates hash tables to convert team names as scraped from BBC fixture pages
#	to team names as used within predict.pl (from create_(euro/summer)teams.pl)

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
@EXPORT_OK  = qw( football_rename rugby_rename );
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
		next if $line eq '' or $line =~ /^#/;
		last if $line eq $dataref->{end_token};
		my ($key, $val) = split ',', $line;
		$dataref->{hashref}->{$key} = $val;
	}
}
close DATA;

sub football_rename {
	return _rename ($_[0], \%football_rename);
}

sub rugby_rename {
	return _rename ($_[0], \%rugby_rename);
}

sub _rename {
	my ($name, $hashref) = @_;
	return unless defined $name;
	return defined $hashref->{ $name }
		? $hashref->{ $name } : $name
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
FC Cincinnati,Cincinnati

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
Nottingham Forest,Nottm Forest
Hull City,Hull
Cardiff City,Cardiff
Burton Albion,Burton
Leeds United,Leeds
Preston North End,Preston
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
Forest Green Rovers,Forest Green
Luton Town,Luton
Grimsby Town,Grimsby
Lincoln City,Lincoln
Exeter City,Exeter
Mansfield Town,Mansfield
Accrington Stanley,Accrington
Coventry City,Coventry
Wycombe Wanderers,Wycombe
Swindon Town,Swindon
Yeovil Town,Yeovil
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
Stockport County,Stockport
Torquay United,Torquay

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

#	Welsh
Llandudno FC,Llandudno
Llanelli Town,Llanelli
Aberystwyth Town,Aberystwyth
Connah's Quay Nomads,Connahs Quay
The New Saints,TNS
Airbus UK Broughton,Airbus
Barry Town United,Barry Town

#	N Irish
Ballymena United,Ballymena
Dungannon Swifts,Dungannon
Institute FC,Institute
Newry City AFC,Newry City
Warrenpoint Town,Warrenpoint

#	Swedish
Helsingborgs,Helsingborg

#	Italian
Inter Milan,Inter
AC Milan,Milan
Hellas Verona,Verona

#	Spanish
Celta Vigo,Celta
Rayo Vallecano,Vallecano
Real Sociedad,Sociedad
Espanyol,Espanol
Athletic Bilbao,Ath Bilbao
Atletico Madrid,Ath Madrid
Real Valladolid,Valladolid
Real Betis,Betis

#	German
Hertha Berlin,Hertha
FC Nuremberg,Nurnberg
FC Schalke,Schalke 04
Mainz 05,Mainz
Borussia Monchengladbach,Mgladbach
Bayer Leverkusen,Leverkusen
Borussia Dortmund,Dortmund
Eintracht Frankfurt,Ein Frankfurt
FC Augsburg,Augsburg
FC Union Berlin,Union Berlin
#SC Freiburg,Freiburg
#RB Leipzig,Leipzig

#	Italian
SPAL,Spal
Inter Milan,Inter
Milan,Milan

#	Australian
Melbourne City FC,Melbourne City
Brisbane Roar FC,Brisbane Roar
Western United FC,Western United
Western Sydney Wanderers FC,Western Sydney Wdrs

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
Cronulla Sutherland Sharks,Cronulla Sharks
St George Illawarra Dragons,St.George Illawarra
Canterbury Bankstown Bulldogs,Canterbury Bulldogs
Manly Warringah Sea Eagles,Manly Sea Eagles
END_RUGBY_TEAMS

The FA Women's Championship,X
Cymru Premier,WL
Irish Premiership,NI
Premier League,E0
Championship,E1
League One,E2
League Two,E3
National League,EC
Scottish Premiership,SC0
Scottish Championship,SC1
Scottish League One,SC2
Scottish League Two,SC3
Irish Premier Division,ROI
Norwegian Eliteserien,NRW
Swedish Allsvenskan,SWD
Finnish Veikkausliiga,FN
United States Major League Soccer,MLS
German Bundesliga,D1
Italian Serie A,I1
Spanish La Liga,SP1
Australian A-League,AUS

Cup,X
The FA,X
FA Cup,X
EFL,X
Spanish Copa del Rey,X
Italian Coppa Italia,X
#Trophy,X
Women,X
International,X
World,X
Euro,X
Champions,X
Friendl,X
Qualifi,X
Group,X
Round,X
Highland League,X
Lowland League,X
Russian Premier League,X
Swiss,X
French,X
Belgian,X
Brazilian,X
Danish,X
Greek,X
Argentine,X
Portuguese,X
Turkish,X
Dutch,X
Austrian,X
Greek,X
Asian,X
UEFA,Xs
END_FOOTBALL_LEAGUES

Betfred Super League,SL
Betfred Championship,CH
Betfred League One,L1
Australian National Rugby League Telstra Premiership,NRL
National Conference Premier,X
National Conference Division 1,X
National Conference Division 2,X
Conference Premier Division,X
Conference Division One,X
Conference Division Two,X
Coral Challenge Cup,X
League 1,L1
Qualifiers,M8
Shield,SH#
Australian,AL
Round,X
Quarter,X
Semi,X
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
