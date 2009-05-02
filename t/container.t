use Test::More tests => 2;

use_ok 'ReportWriter::Container';

ok( my $container = ReportWriter::Container->new( ), 'New Container' );
