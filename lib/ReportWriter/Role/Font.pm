package ReportWriter::Role::Font;

use 5.010;
use Moose::Role;

has 'fontface' => (
    isa => 'Str',
    is  => 'rw',
    default => 'Helvetica',
);
has 'fontsize' => (
    isa => 'Int',
    is  => 'rw',
    default => 10,
);

no Moose::Role;

1;