use Test::More tests => 3;

use_ok 'ReportWriter::Footer';
use_ok 'ReportWriter::Container';

ok( my $footer = ReportWriter::Footer->new( ), 'New Footer' );
