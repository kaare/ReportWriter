use Test::More tests => 6;

use_ok 'ReportWriter::Box';

ok( my $box = ReportWriter::Box->new( startx => 100, starty => 10 ), 'New Box' );
ok( $box->height(400), 'Add a height' );
is( $box->height, 400, 'Check if height is correct' );
ok( $box->type('rounded'), 'Add a type' );
is( $box->type, 'rounded', 'Check if type is correct' );
