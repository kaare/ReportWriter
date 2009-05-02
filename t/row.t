use Test::More tests => 8;

use_ok 'ReportWriter::Row';
use_ok 'ReportWriter::Column';

ok( my $row = ReportWriter::Row->new( ), 'New Row' );
ok( my $col = ReportWriter::Column->new( name => 'Column', align => 'left' ), 'New Column' );
ok($row->add_columns($col), 'Add column');
is($row->columns->[0], $col, 'Correct column');
ok($row->remove_last_column, 'Remove column');
is_deeply($row->columns, [], 'No columns');
