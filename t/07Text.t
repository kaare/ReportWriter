#!perl

use strict;
use warnings;
use Test::More;
use DBI;
use File::Slurp;
use ReportWriter;


BEGIN {
    eval { require DBD::SQLite } or plan skip_all => "DBD::SQLite is required for this test";

    plan tests => 5;
}

# connect to the database
my $db_file = 't/_reportwriter_test_.db';
die 'Test database not found!' unless ( -e $db_file );

my $dbh = DBI->connect("dbi:SQLite:$db_file") or die $DBI::errstr;

my ($config, $expected);
eval `cat t/07Textdata` or die "Can't find t/07Textdata: $!"; 

ok(my $report = ReportWriter->new(config_file => 't/07Text.yml', type => 'PDF', filename => '/tmp/a.pdf'), 'New ReportWriter::Config');
ok($report->config->report, 'Config is OK');

my $sql = 'SELECT * FROM product JOIN inventory USING (name) ORDER BY product_group';
ok(my $products = $dbh->selectall_arrayref($sql, { Slice => {} }),'Select all products w/inventory');

ok(my $output = $report->output, 'New ReportWriter');
$output->page_data({ invoicenr => 123456 });
$output->row($_) for @{ $products };
ok(my $result = $output->result(),'Get result');
write_file( 't/07Text.pdf', $result); ## Do this in ReportWriter if providing a filename
=head2
$rep->row($_) for @{ $products };
ok(my $result = $rep->result(),'Get result');
is($result, $expected, 'Returned result is OK');
#use Data::Dumper;print STDERR Dumper $result;
=cut
