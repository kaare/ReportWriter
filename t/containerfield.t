use Test::More tests => 4;

use_ok 'ReportWriter::Containerfield';

ok( my $field = ReportWriter::Containerfield->new( name => 'Containerfield', align => 'left' ), 'New Containerfield' );
is( $field->name, 'Containerfield', 'Check if name is correct' );
is( $field->align, 'left', 'Check if align enum is correct' );
