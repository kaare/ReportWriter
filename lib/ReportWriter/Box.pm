package ReportWriter::Box;

use 5.010;
use Moose;
use ReportWriter::Types;

with 'ReportWriter::Role::Position';

has 'fill' => (
    isa     => 'Num',
    is      => 'rw',
    default => 0,
);
has 'type' => (
    isa     => 'boxtype',
    is      => 'rw',
    default => 'normal',
);
has 'thickness' => (
    isa     => 'Num',
    is      => 'rw',
    default => 1,
);

no Moose;

1;
