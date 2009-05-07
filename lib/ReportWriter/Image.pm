package ReportWriter::Image;

use 5.010;
use Moose;

with 'ReportWriter::Role::Position';

has 'filename' => (
    isa => 'Str',
    is  => 'rw',
);
has 'scale' => (
    isa     => 'Num',
    is      => 'rw',
    default => 1,
);

no Moose;

1;
