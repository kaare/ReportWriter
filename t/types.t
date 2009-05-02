package test;

use Moose;
use ReportWriter::Types;

has 'align' => (
    isa => 'alignment',
    is  => 'rw',
);
has 'direction' => (
    isa => 'direction',
    is  => 'rw',
);

package test2;
use Test::More tests => 3;

ok(my $test = test->new(align => 'right', direction => 'horizontal'), 'New test');
is($test->align, 'right', 'Alignment is right');
is($test->direction, 'horizontal', 'Direction is right');
