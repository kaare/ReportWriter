package ReportWriter::Report;

use 5.010;
use Moose;
use ReportWriter::Types;

has 'unit' => (
    isa       => 'unit',
    is        => 'rw',
    predicate => 'has_unit',
);
has 'rows' => (
    traits => [ 'Array' ],
    is        => 'ro',
    isa       => 'ArrayRef[ReportWriter::Row]',
    default   => sub { [] },
    handles  => {
        add_rows      => 'push',
        remove_last_row => 'pop',
    }
);
has 'totals' => (
    traits => [ 'Array' ],
    is        => 'ro',
    isa       => 'ArrayRef[ReportWriter::Total]',
    default   => sub { [] },
    handles  => {
        add_totals      => 'push',
        remove_last_total => 'pop',
    }
);
has 'images' => (
    traits => [ 'Array' ],
    is        => 'ro',
    isa       => 'ArrayRef[ReportWriter::Image]',
    default   => sub { [] },
    handles  => {
        add_images      => 'push',
        remove_last_image => 'pop',
    }
);
has 'boxes' => (
    traits => [ 'Array' ],
    is        => 'ro',
    isa       => 'ArrayRef[ReportWriter::Box]',
    default   => sub { [] },
    handles  => {
        add_boxes     => 'push',
        remove_last_box => 'pop',
    }
);
has page => (
    isa => 'Maybe[ReportWriter::Page]',
    is  => 'rw',
);
has header => (
    isa => 'Maybe[ReportWriter::Header]',
    is  => 'rw',
);
has body => (
    isa => 'Maybe[ReportWriter::Body]',
    is  => 'rw',
);
has footer => (
    isa => 'Maybe[ReportWriter::Footer]',
    is  => 'rw',
);
has papername => (
    isa     => 'Str',
    is      => 'rw',
    default => 'A4',
);
has orientation => (
    isa     => 'orientation',
    is      => 'rw',
    default => 'portrait'
);

no Moose;

1;
