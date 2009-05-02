use Test::More tests => 3;

use_ok 'ReportWriter::Header';
use_ok 'ReportWriter::Container';

ok( my $header = ReportWriter::Header->new( ), 'New Header' );
