package ReportWriter::Role::Position;

use 5.010;
use Moose::Role;
use ReportWriter::Types;

has 'startx' => (
    isa     => 'Num',
    is      => 'rw',
    default => 0,
);
has 'starty' => (
    isa     => 'Num',
    is      => 'rw',
    default => 0,
);
has 'width' => (
    isa     => 'Num',
    is      => 'rw',
    default => 0,
);
has 'height' => (
    isa     => 'Num',
    is      => 'rw',
    default => 0,
);

no Moose::Role;

1;
