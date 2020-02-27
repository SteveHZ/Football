package Football::BackTest::Recent_Predictions;

use Moo;
use namespace::clean;

extends 'Football::Game_Predictions::Recent_Model';
with 'Football::BackTest::Roles::Game_Predictions';

1;
