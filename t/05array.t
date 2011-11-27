#!perl

use strict;
use warnings;
use Test::More;
use DBI;
use ReportWriter::Config;

BEGIN {
    eval { require DBD::SQLite }
      or plan skip_all => "DBD::SQLite is required for this test";
}

# connect to the database
my $db_file = 't/_reportwriter_test_.db';
die 'Test database not found!' unless ( -e $db_file );

my $dbh = DBI->connect("dbi:SQLite:$db_file") or die $DBI::errstr;

my $array;
eval `cat t/05arraydata` or die "Can't find t/05arraydata"; 

ok(my $config = ReportWriter::Config->new(output => 'Array', config => 't/05array.yml'), 'New ReportWriter::Config');
ok($config, 'Config is OK');

my $sql = 'SELECT * FROM product ORDER BY product_group';
ok(my $products = $dbh->selectall_arrayref($sql),'Select all products');

$sql = 'SELECT * FROM product JOIN inventory USING (name) ORDER BY product_group';
ok($products = $dbh->selectall_arrayref($sql, { Slice => {} }),'Select all products w/inventory');

done_testing();

=pod
my $i=1;
is($rep->row($_), undef,"Row ".$i++) for @{ $products };

ok(my $result = $rep->result,'Get back the result as array');
is_deeply($result, $array, 'Returned array is OK');
#use Data::Dumper;print STDERR Dumper $result;
=cut