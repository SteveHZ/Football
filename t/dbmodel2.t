This module can generate pretty complicated WHERE statements easily. For example, simple key=value pairs are taken to mean equality, and if you want to see if a field is within a set of values, you can use an arrayref. Let's say we wanted to SELECT some data based on this criteria:

    my %where = (
       requestor => 'inna',
       status => { '!=', 'completed' }
       worker => ['nwiger', 'rcwe', 'sfz'],
    );

    my($stmt, @bind) = $sql->select('tickets', '*', \%where);

The above would give you something like this:

    $stmt = "SELECT * FROM tickets WHERE
                ( requestor = ? ) AND ( status != ? )
                AND ( worker = ? OR worker = ? OR worker = ? )";
    @bind = ('inna', 'completed', 'nwiger', 'rcwe', 'sfz');

Which you could then use in DBI code like so:

    my $sth = $dbh->prepare($stmt);
    $sth->execute(@bind);
	
select * from league where (home_team = ? and result = ('h' or 'd'))
or (away _team = ? and result = ('a' or 'd'))
where = (

)