use Test::More tests => 4;

use_ok 'ReportWriter::Body';

ok( my $body = ReportWriter::Body->new( startx => 100, starty => 10 ), 'New Body' );
ok( $body->height(400), 'Add a height' );
is( $body->height, 400, 'Check if height is correct' );
