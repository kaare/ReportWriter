package ReportWriter::Field;

use 5.010;
use Moose;
use ReportWriter::Types;

with 'ReportWriter::Role::Font';

has 'name' => (
    isa => 'Str',
    is  => 'rw',
);
has 'width' => (
    isa     => 'Num',
    is      => 'rw',
    default => 25,
);
has 'height' => (
    isa     => 'Num',
    is      => 'rw',
#    default => 12,
);
has 'label' => (
    isa => 'Str',
    is  => 'rw',
);
has 'text' => (
    isa => 'Str',
    is  => 'rw',
);
has 'align' => (
    isa     => 'alignment',
    is      => 'rw',
    default => 'left',
);
has 'result' => (
    isa => 'Str',
    is  => 'ro',
);

no Moose;

1;
