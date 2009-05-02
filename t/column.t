use Test::More tests => 4;

use_ok 'ReportWriter::Column';

ok( my $col = ReportWriter::Column->new( name => 'Column', align => 'left' ), 'New Column' );
is( $col->name, 'Column', 'Check if name is correct' );
is( $col->align, 'left', 'Check if align enum is correct' );
