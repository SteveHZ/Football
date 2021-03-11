=begin comment
#this is from Reports::Head2Head line 88 but think that bit is ok,
#next line in create_reports.pl creates new Reports::Favourites object

# ** something to do with 2019 season has 'time' column **
# maybe regex fucks up with :


*** SEE Football/data/favourites/Premier League/2019.csv" ***
** file is written weekly from predict.pl 2019 = 21/7/20 2020 = 10/3/21


Creating hash for Premier League...
Creating hash for Championship...
Creating hash for League One...
Creating hash for League Two...
Creating hash for Conference...
Creating hash for Scots Premier...
Creating hash for Scots Championship...
Creating hash for Scots League One...
Creating hash for Scots League Two...

Use of uninitialized value $data[0] in string eq at C:/Mine/perl/Football/Football/Favourites/Data_Model.pm line 17, <$fh> line 3.
Use of uninitialized value $data[0] in string eq at C:/Mine/perl/Football/Football/Favourites/Data_Model.pm line 17, <$fh> line 3.
Use of uninitialized value $data[0] in string eq at C:/Mine/perl/Football/Football/Favourites/Data_Model.pm line 17, <$fh> line 3.
Use of uninitialized value $data[0] in string eq at C:/Mine/perl/Football/Football/Favourites/Data_Model.pm line 17, <$fh> line 3.
Use of uninitialized value $data[0] in string eq at C:/Mine/perl/Football/Football/Favourites/Data_Model.pm line 17, <$fh> line 3.
Use of uninitialized value $data[0] in string eq at C:/Mine/perl/Football/Football/Favourites/Data_Model.pm line 17, <$fh> line 3.
Use of uninitialized value $data[0] in string eq at C:/Mine/perl/Football/Football/Favourites/Data_Model.pm line 17, <$fh> line 3.
Use of uninitialized value $data[0] in string eq at C:/Mine/perl/Football/Football/Favourites/Data_Model.pm line 17, <$fh> line 3.
Use of uninitialized value $data[0] in string eq at C:/Mine/perl/Football/Football/Favourites/Data_Model.pm line 17, <$fh> line 3.

with extra error messages :

# Not due to string length - many more data fields for 2019.csv but did copy then deleted everthing after 'referee'
# for Premier League/2019.csv and error still occurred ??

Creating hash for Premier League...
Creating hash for Championship...
Creating hash for League One...
Creating hash for League Two...
Creating hash for Conference...
Creating hash for Scots Premier...
Creating hash for Scots Championship...
Creating hash for Scots League One...
Creating hash for Scots League Two...

Use of uninitialized value $data[0] in join or string at C:/Mine/perl/Football/Football/Favourites/Data_Model.pm line 42, <$fh> line 3.
Use of uninitialized value $data[1] in join or string at C:/Mine/perl/Football/Football/Favourites/Data_Model.pm line 42, <$fh> line 3.
Use of uninitialized value $data[2] in join or string at C:/Mine/perl/Football/Football/Favourites/Data_Model.pm line 42, <$fh> line 3.
Use of uninitialized value $data[3] in join or string at C:/Mine/perl/Football/Football/Favourites/Data_Model.pm line 42, <$fh> line 3.
Use of uninitialized value $data[4] in join or string at C:/Mine/perl/Football/Football/Favourites/Data_Model.pm line 42, <$fh> line 3.
Use of uninitialized value $data[5] in join or string at C:/Mine/perl/Football/Football/Favourites/Data_Model.pm line 42, <$fh> line 3.
4 1 H 1.14 10 19

Use of uninitialized value $data[0] in string eq at C:/Mine/perl/Football/Football/Favourites/Data_Model.pm line 44, <$fh> line 3.
Error : C:/Mine/perl/Football/data/favourites/Premier League/2019.csv
Use of uninitialized value $data[0] in join or string at C:/Mine/perl/Football/Football/Favourites/Data_Model.pm line 42, <$fh> line 3.
Use of uninitialized value $data[1] in join or string at C:/Mine/perl/Football/Football/Favourites/Data_Model.pm line 42, <$fh> line 3.
Use of uninitialized value $data[2] in join or string at C:/Mine/perl/Football/Football/Favourites/Data_Model.pm line 42, <$fh> line 3.
Use of uninitialized value $data[3] in join or string at C:/Mine/perl/Football/Football/Favourites/Data_Model.pm line 42, <$fh> line 3.
Use of uninitialized value $data[4] in join or string at C:/Mine/perl/Football/Football/Favourites/Data_Model.pm line 42, <$fh> line 3.
Use of uninitialized value $data[5] in join or string at C:/Mine/perl/Football/Football/Favourites/Data_Model.pm line 42, <$fh> line 3.
3 3 D 2.37 3.3 3.3

Use of uninitialized value $data[0] in string eq at C:/Mine/perl/Football/Football/Favourites/Data_Model.pm line 44, <$fh> line 3.
Error : C:/Mine/perl/Football/data/favourites/Championship/2019.csv
Use of uninitialized value $data[0] in join or string at C:/Mine/perl/Football/Football/Favourites/Data_Model.pm line 42, <$fh> line 3.
Use of uninitialized value $data[1] in join or string at C:/Mine/perl/Football/Football/Favourites/Data_Model.pm line 42, <$fh> line 3.
Use of uninitialized value $data[2] in join or string at C:/Mine/perl/Football/Football/Favourites/Data_Model.pm line 42, <$fh> line 3.
Use of uninitialized value $data[3] in join or string at C:/Mine/perl/Football/Football/Favourites/Data_Model.pm line 42, <$fh> line 3.
Use of uninitialized value $data[4] in join or string at C:/Mine/perl/Football/Football/Favourites/Data_Model.pm line 42, <$fh> line 3.
Use of uninitialized value $data[5] in join or string at C:/Mine/perl/Football/Football/Favourites/Data_Model.pm line 42, <$fh> line 3.
1 2 A 2.6 3.4 2.87

Use of uninitialized value $data[0] in string eq at C:/Mine/perl/Football/Football/Favourites/Data_Model.pm line 44, <$fh> line 3.
Error : C:/Mine/perl/Football/data/favourites/League One/2019.csv
Use of uninitialized value $data[0] in join or string at C:/Mine/perl/Football/Football/Favourites/Data_Model.pm line 42, <$fh> line 3.
Use of uninitialized value $data[1] in join or string at C:/Mine/perl/Football/Football/Favourites/Data_Model.pm line 42, <$fh> line 3.
Use of uninitialized value $data[2] in join or string at C:/Mine/perl/Football/Football/Favourites/Data_Model.pm line 42, <$fh> line 3.
Use of uninitialized value $data[3] in join or string at C:/Mine/perl/Football/Football/Favourites/Data_Model.pm line 42, <$fh> line 3.
Use of uninitialized value $data[4] in join or string at C:/Mine/perl/Football/Football/Favourites/Data_Model.pm line 42, <$fh> line 3.
Use of uninitialized value $data[5] in join or string at C:/Mine/perl/Football/Football/Favourites/Data_Model.pm line 42, <$fh> line 3.
2 0 H 1.9 3.6 4.5
