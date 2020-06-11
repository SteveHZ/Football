#   poisson.t 02/03/20

use Football::Game_Predictions::Poisson;
use MyHeader;
use Test::More tests => 4;

my $home_expect = 2.02;
my $away_expect = 0.53;

my $expected = [ '7.808', '4.138', '1.097', '0.194', '0.026', '0.003' ];
my $expected2 = [ '15.772', '8.359', '2.215', '0.391', '0.052', '0.005' ];

my $p = Football::Game_Predictions::Poisson->new (weighted => 0);
my $stats = $p->calc_poisson ($home_expect, $away_expect);

is_deeply (@$stats[0], $expected, 'stats [0] ok');
is_deeply (@$stats[1], $expected2, 'stats [1] ok');

my $expected3 = [ '8.609', '4.302', '1.14', '0.201', '0.027', '0.003' ];
my $expected4 = [ '16.396', '8.193', '2.171', '0.384', '0.051', '0.005' ];

my $p2 = Football::Game_Predictions::Poisson->new (weighted => 1);
my $stats2 = $p2->calc_poisson ($home_expect, $away_expect);

is_deeply (@$stats2[0], $expected3, 'weighted stats [0] ok');
is_deeply (@$stats2[1], $expected4, 'weighted stats [1] ok');

=head
#Data::Dumper for expect values 2.02,0.53, max 10
$VAR1 = [
          [
            '7.80816660011532',
            '4.13832829806112',
            '1.0966569989862',
            '0.193742736487561',
            '0.025670912584601',
            '0.00272111673396769',
            '0.000240365311500772',
            '1.81990878701036e-05',
            '1.20568957160976e-06',
            '7.10017198224919e-08',
            '3.76309028460242e-09'
          ],
          [
            '15.7724965322329',
            '8.35942316208346',
            '2.21524713795212',
            '0.391360327704874',
            '0.051855243420894',
            '0.00549665580261474',
            '0.000485537929231558',
            '3.67621574976094e-05',
            '2.43549293465171e-06',
            '1.43423474041434e-07',
            '7.60144237489689e-09'
          ],
          [
            '15.9302214975553',
            '8.44301739370429',
            '2.23739960933164',
            '0.395273930981923',
            '0.0523737958551029',
            '0.00555162236064088',
            '0.000490393308523874',
            '3.71297790725854e-05',
            '2.45984786399823e-06',
            '1.44857708781848e-07',
            '7.67745679864585e-09'
          ],
          [
            '10.7263491416872',
            '5.68496504509422',
            '1.50651573694997',
            '0.266151113527828',
            '0.035265022542436',
            '0.0037380923894982',
            '0.000330198161072742',
            '2.50007179088742e-05',
            '1.65629756175881e-06',
            '9.7537523913111e-08',
            '5.16948757775487e-09'
          ],
          [
            '5.41680631655204',
            '2.87090734777258',
            '0.760790447159734',
            '0.134406312331553',
            '0.0178088363839301',
            '0.00188773665669659',
            '0.000166750071341735',
            '1.26253625439815e-05',
            '8.36430268688198e-07',
            '4.9256449576121e-08',
            '2.61059122676621e-09'
          ],
          [
            '2.18838975188703',
            '1.15984656850013',
            '0.307359340652533',
            '0.0543001501819476',
            '0.0071947698991078',
            '0.000762645609305424',
            '6.7367028822061e-05',
            '5.10064646776853e-06',
            '3.37917828550033e-07',
            '1.98996056287529e-08',
            '1.05467885561355e-09'
          ],
          [
            '0.7367578831353',
            '0.390481678061709',
            '0.103477644686353',
            '0.0182810505612557',
            '0.00242223919936629',
            '0.000256757355132826',
            '2.26802330367605e-05',
            '1.71721764414874e-06',
            '1.13765668945178e-07',
            '6.69953389501349e-09',
            '3.55075214723229e-10'
          ],
          [
            '0.212607274847607',
            '0.112681855669232',
            '0.0298606917523464',
            '0.00527538887624787',
            '0.000698989026102818',
            '7.40928367668984e-05',
            '6.54486724775065e-06',
            '4.95539948740046e-07',
            '3.28295216098929e-08',
            '1.93329406684668e-09',
            '1.02464561962985e-10'
          ],
          [
            '0.0536833368990284',
            '0.028452168556485',
            '0.00753982466746854',
            '0.00133203569125278',
            '0.000176494729090986',
            '1.87084412836445e-05',
            '1.65257898005727e-06',
            '1.25123837056879e-07',
            '8.28945420649913e-09',
            '4.88156751878855e-10',
            '2.58723018956574e-11'
          ],
          [
            '0.0120489267262222',
            '0.00638593116489778',
            '0.00169227175869791',
            '0.000298968010703298',
            '3.96132614181855e-05',
            '4.19900571032765e-06',
            '3.70912171079393e-07',
            '2.80833500949788e-08',
            '1.86052194412472e-09',
            '1.09564070977216e-10',
            '5.80689442546777e-12'
          ],
          [
            '0.00243388319869989',
            '0.00128995809531094',
            '0.0003418388952574',
            '6.03915381621407e-05',
            '8.00187880648336e-06',
            '8.48199153487233e-07',
            '7.49242585581299e-08',
            '5.67283671919271e-09',
            '3.75825432713657e-10',
            '2.2131942337425e-11',
            '1.17299267394594e-12'
          ]
        ];
=cut