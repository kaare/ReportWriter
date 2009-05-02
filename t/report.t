use Test::More tests => 3;

use_ok 'ReportWriter::Report';
use_ok 'ReportWriter::Row';

ok( my $report = ReportWriter::Report->new( ), 'New Report' );
