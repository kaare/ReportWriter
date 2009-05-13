use Test::More tests => 6;

use_ok 'ReportWriter::Image';

ok( my $image = ReportWriter::Image->new( startx => 100, starty => 10 ), 'New Image' );
ok( $image->scale(.5), 'Add a scale' );
is( $image->scale, .5, 'Check if scale is correct' );
ok( $image->filename('etc/image.jpg'), 'Add a filename' );
is( $image->filename, 'etc/image.jpg', 'Check if filename is correct' );
