package ReportWriter::Body;

use 5.010;
use Moose;

with 'ReportWriter::Role::Position';

has 'header' => ( ## Some way to define a body header
    isa => 'Str',
    is  => 'rw',
);

no Moose;

1;
