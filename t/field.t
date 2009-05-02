use Test::More tests => 12;

use_ok 'ReportWriter::Field';

ok( my $field = ReportWriter::Field->new( align => 'left' ), 'New Field' );
ok( $field->name('Col1'), 'Name field' );
is( $field->align, 'left', 'Check if align enum is correct' );
ok( $field->align('right'), 'Change alignment' );
is( $field->align, 'right', 'Check if align enum is still correct' );
eval { $field->align('wrong') };
ok( $@, 'Change alignment wrong dies' );
is( $field->align, 'right', 'Check if align enum is still correct' );
ok($field->width(25), 'Set width');
is ($field->cwidth, 25, 'Check cwidth is the same as width');
ok($field->unit('pt'), 'Set resulting unit to pt');
is($field->cwidth, 70.86615725,'Check that cwidth is converted')
