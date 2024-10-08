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
	%womens_football_fixtures_leagues
);
@EXPORT_OK  = qw( football_rename rugby_rename );
%EXPORT_TAGS = (all => [ @EXPORT, @EXPORT_OK ]);

sub new { return bless {}, shift; }

our %football_rename = ();
our %rugby_rename = ();
our %football_fixtures_leagues = ();
our %womens_football_fixtures_leagues = ();
our %rugby_fixtures_leagues = ();

my @datarefs = (
	{ hashref => \%football_rename, end_token => 'END_FOOTBALL_TEAMS' },
	{ hashref => \%rugby_rename, end_token => 'END_RUGBY_TEAMS' },
	{ hashref => \%football_fixtures_leagues, end_token => 'END_FOOTBALL_LEAGUES' },
	{ hashref => \%rugby_fixtures_leagues, end_token => 'END_RUGBY_LEAGUES' },
	{ hashref => \%womens_football_fixtures_leagues, end_token => 'END_WOMENS_FOOTBALL_LEAGUES' },
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
#	English
Brighton & Hove Albion,Brighton
Manchester City,Man City
Manchester United,Man Utd
Sheffield United,Sheff Utd
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
Nottingham Forest,Notts Forest
Hull City,Hull
Cardiff City,Cardiff
Burton Albion,Burton
Leeds United,Leeds
Preston North End,Preston
Bolton Wanderers,Bolton
Norwich City,Norwich
Sheffield Wednesday,Sheff Wed
Wolverhampton Wanderers,Wolves
Queens Park Rangers,QPR
Middlesbrough,Middlesboro
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
Crawley Town,Crawley
Fleetwood Town,Fleetwood
Forest Green Rovers,Forest Green
Luton Town,Luton
Grimsby Town,Grimsby
Milton Keynes Dons,MK Dons
Lincoln City,Lincoln
Exeter City,Exeter
Mansfield Town,Mansfield
AFC Wimbledon,Wimbledon
Accrington Stanley,Accrington
Coventry City,Coventry
Wycombe Wanderers,Wycombe
Swindon Town,Swindon
Yeovil Town,Yeovil
Newport County,Newport
AFC Fylde,Fylde
FC Halifax Town,Halifax
Dagenham & Redbridge,Dag and Red
Maidstone United,Maidstone
Hartlepool United,Hartlepool
Harrogate Town,Harrogate
Solihull Moors,Solihull
Aldershot Town,Aldershot
Dorking Wanderers,Dorking
Tranmere Rovers,Tranmere
Ebbsfleet United,Ebbsfleet
Maidenhead United,Maidenhead
Sutton United,Sutton
Salford City,Salford
Stockport County,Stockport
York City,York,
Boston United,Boston
Braintree Town,Braintree
#Torquay United,Torquay
#King's Lynn Town,Kings Lynn
#Kidderminster Harriers,Kidderminster
#Macclesfield Town,Macclesfield

#	Scottish
Dundee United,Dundee Utd
Partick Thistle,Partick
Hamilton Academical,Hamilton
Heart of Midlothian,Hearts
Queen of the South,Queen of Sth
Inverness CT,Inverness
Greenock Morton,Morton
Alloa Athletic,Alloa
Ayr United,Ayr
Queen's Park,Queens Park
Airdrieonians,Airdrie
Raith Rovers,Raith Rvs
Forfar Athletic,Forfar
Elgin City,Elgin
Stirling Albion,Stirling
Edinburgh City,Edinburgh
The Spartans,Spartans
Dunfermline Athletic,Dunfermline
St. Johnstone,St Johnstone
St. Mirren,St Mirren
#Berwick Rangers,Berwick
#Brechin City,Brechin
#Albion Rovers,Albion Rvs

#	Irish
St Patrick's Athletic,St Patricks
Sligo Rovers,Sligo Rvs
Shamrock Rovers,Shamrock Rvs
Drogheda United,Drogheda
Galway United FC,Galway
#Longford Town,Longford

#	American
Chicago Fire FC,Chicago Fire
Columbus,Columbus Crew
D.C. United,DC United
Houston Dynamo FC,Houston Dynamo
Minnesota United FC,Minnesota
Atlanta United,Atlanta Utd
New York City FC,New York City
Seattle Sounders FC,Seattle Sounders
Vancouver Whitecaps FC,Vancouver
Los Angeles Football Club,Los Angeles
FC Cincinnati,Cincinnati
Orlando City SC,Orlando City
Inter Miami CF,Inter Miami
CF Montreal,Montreal
New England Revolution,New England Rev
Philadelphia Union,Philadelphia
San Jose Earthquakes,San Jose
New York Red Bulls,New York RB
Sporting Kansas City,Sporting Kansas
Charlotte FC,Charlotte
Austin FC,Austin
Toronto FC,Toronto

 #	Welsh
#Llandudno FC,Llandudno
#Llanelli Town,Llanelli
#Aberystwyth Town,Aberystwyth
#Connah's Quay Nomads,Connahs Quay
#The New Saints,TNS
#Airbus UK Broughton,Airbus
#Barry Town United,Barry Town

#	N Irish
#Ballymena United,Ballymena
#Dungannon Swifts,Dungannon
#Institute FC,Institute
#Newry City AFC,Newry City
#Warrenpoint Town,Warrenpoint

#	Irish
Galway United,Galway

#	Swedish
Helsingborgs,Helsingborg
Brommapojkarna,Brommapj
Halmstad,Halmstads
Djurgarden,Djurgardens
Varberg,Varbergs

#	Finnish
AC Oulu,Oulu
#HJK,HJK Helsinki

#	Norwegian
Bodo   Glimt,Bodo Glimt

#	Italian
Internazionale,Inter
AC Milan,Milan
Hellas Verona,Verona
#SPAL,Spal

#	Spanish
Celta de Vigo,Celta
Rayo Vallecano,Vallecano
Real Sociedad,Sociedad
#Espanyol,Espanol
Athletic Club,Ath Bilbao
Atletico Madrid,Ath Madrid
Real Betis,Betis
Cádiz,Cadiz
Deportivo Alaves,Alaves
#Real Valladolid,Valladolid

#	German
Mainz 05,Mainz
Borussia M'gladbach,Mgladbach
Bayer Leverkusen,Leverkusen
Borussia Dortmund,Dortmund
Eintracht Frankfurt,Frankfurt
FC Augsburg,Augsburg
FC Union Berlin,Union Berlin
SC Freiburg,Freiburg
VfL Bochum 1848,Bochum
FC Heidenheim,Heidenheim
Bayern Munchen,Bayern Munich
#Hertha Berlin,Hertha
#FC Nuremberg,Nurnberg
#FC Schalke,Schalke
#SpVgg Greuther Furth,Greuther Furth
#Arminia Bielefeld,Bielefeld

#	French
Paris Saint Germain,PSG
Olympique Lyonnais,Lyon
Olympique Marseille,Marseille
Angers SCO,Angers
Saint-Etienne,St Etienne

#	Australian
#Melbourne City FC,Melbourne City
#Brisbane Roar FC,Brisbane Roar
#Western United FC,Western United
#Western Sydney Wanderers FC,Western Sydney Wdrs
END_FOOTBALL_TEAMS

#	Rugby League
# This line used in Fixtures_Globals.t - DO NOT UNCOMMENT !!
Huddersfield Giants,Huddersfield
Hull FC,Hull
Bradford Bulls,Bradford
York Knights,York
Batley Bulldogs,Batley
Hurricanes,Midlands
Crusaders,Nth Wales

Melbourne Storm,Melbourne
Penrith Panthers,Penrith
Sydney Roosters,Sydney
Cronulla Sharks,Cronulla
Canterbury Bulldogs,Canterbury
North Queensland Cowboys,Nth Queens
Manley Sea Eagles,Manly
St. George Illawarra Dragons,St George
Canberra Raiders,Canberra
Gold Coast Titans,Gold Coast
Newcastle Knights,Newcastle
South Sydney Rabbitohs,Sth Sydney
Parramatta Eels,Parramatta
Wests Tigers,Wests


#Leigh,Leigh Centurions
#Castleford,Castleford Tigers
#Wakefield,Wakefield Trinity
#Wigan,Wigan Warriors
#Leeds,Leeds Rhinos
#Hudd'sfld,Huddersfield
#Salford,Salford Red Devils
#Warrington,Warrington Wolves
#Catalans,Catalans Dragons
#Widnes,Widnes Vikings
#Dewsbury,Dewsbury Rams
#Rochdale,Rochdale Hornets
#Toulouse,Toulouse Olympique
#London,London Broncos
#Featherstone,Featherstone Rovers
#Toronto,Toronto Wolfpack
#Barrow,Barrow Raiders
#York,York City Knights
#Coventry,Coventry Bears
#Hunslet,Hunslet Hawks
#Keighley,Keighley Cougars
#Crusaders,North Wales Crusaders
#Raiders,West Wales Raiders
#Workington,Workington Town
#Newcastle,Newcastle Thunder
#Bradford,Bradford Bulls
#Cronulla Sutherland Sharks,Cronulla Sharks
#St George Illawarra Dragons,St.George Illawarra
#Canterbury Bankstown Bulldogs,Canterbury Bulldogs
#Manly Warringah Sea Eagles,Manly Sea Eagles
END_RUGBY_TEAMS

Premier League,E0
Championship,E1
League One,E2
League Two,E3
National League,EC
Scottish Premiership,SC0
Scottish Championship,SC1
Scottish League One,SC2
Scottish League Two,SC3
Irish Premier League,ROI
Norwegian Eliteserien,NOR
Swedish Allsvenskan,SWE
Finnish Veikkausliiga,FIN
German Bundesliga,D1
Italian Serie A,I1
Spanish La Liga,SP1
French Ligue 1,F1
#Australian A-League,AUS

Cup,X
The FA,X
FA Cup,X
Scottish League Cup,X
EFL,X
Cymru Premier,X
Welsh Premier League,X
Irish Premiership,X
Spanish Copa del Rey,X
Italian Coppa Italia,X
Coppa Italia,X
French Coupe de France,X
FA Trophy,X
Trophy,X
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
Credit Suisse Super League,X
Polish Ekstraklasa,X
#French,X
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
UEFA,X
US Major League Soccer,X
Australian A-League,X
Copa Libertadores,X
CONMEBOL Libertadores,X
Saudi Professional League,X
Saudi League,X
Women,X
Women's Super League,X
Women's Championship,X
END_FOOTBALL_LEAGUES

Betfred Super League,SL
Betfred Championship,CH
Betfred League One,L1
Australian National Rugby League Telstra Premiership,NRL
#National Conference Premier,X
#National Conference Division 1,X
#National Conference Division 2,X
#Conference Premier Division,X
#Conference Division One,X
#Conference Division Two,X
#Coral Challenge Cup,X
#League 1,L1
#Qualifiers,M8
#Shield,SH
#Australian,AL
#Round,X
#Quarter,X
#Semi,X
END_RUGBY_LEAGUES

The FA Women's Super League,X
The FA Women's Champ,X
Scottish Women's Prem,X
#Women,X
END_WOMENS_FOOTBALL_LEAGUES

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
