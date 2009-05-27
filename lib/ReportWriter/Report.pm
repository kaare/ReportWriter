package ReportWriter::Report;

use 5.010;
use Moose;
use MooseX::AttributeHelpers;
use ReportWriter::Types;

has 'unit' => (
    isa       => 'unit',
    is        => 'rw',
    predicate => 'has_unit',
);
has 'rows' => (
    metaclass => 'Collection::Array',
    is        => 'ro',
    isa       => 'ArrayRef[ReportWriter::Row]',
    default   => sub { [] },
    provides  => {
        'push' => 'add_rows',
        'pop'  => 'remove_last_row',
    }
);
has 'totals' => (
    metaclass => 'Collection::Array',
    is        => 'ro',
    isa       => 'ArrayRef[ReportWriter::Total]',
    default   => sub { [] },
    provides  => {
        'push' => 'add_totals',
        'pop'  => 'remove_last_total',
    }
);
has 'images' => (
    metaclass => 'Collection::Array',
    is        => 'ro',
    isa       => 'ArrayRef[ReportWriter::Image]',
    default   => sub { [] },
    provides  => {
        'push' => 'add_images',
        'pop'  => 'remove_last_image',
    }
);
has 'boxes' => (
    metaclass => 'Collection::Array',
    is        => 'ro',
    isa       => 'ArrayRef[ReportWriter::Box]',
    default   => sub { [] },
    provides  => {
        'push' => 'add_boxes',
        'pop'  => 'remove_last_box',
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
