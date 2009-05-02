package ReportWriter::Report;

use 5.010;
use Moose;
use MooseX::AttributeHelpers;
use ReportWriter::Types;

has 'unit' => (
    isa => 'unit',
    is  => 'rw',
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

after 'add_rows' => sub {
    my ( $self, @columns ) = @_;

    # Do what's necessary to make a row work in a report environment
};

no Moose;

1;
