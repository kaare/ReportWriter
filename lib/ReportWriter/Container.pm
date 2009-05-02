package ReportWriter::Container;

use 5.010;
use Moose;
use MooseX::AttributeHelpers;
use ReportWriter::Types;

with 'ReportWriter::Role::Position';

has 'fields' => (
    metaclass => 'Collection::Array',
    is        => 'ro',
    isa       => 'ArrayRef[ReportWriter::Containerfield]',
    default   => sub { [] },
    provides  => {
        'push' => 'add_fields',
        'pop'  => 'remove_last_field',
    }
);
has 'direction' => (
    isa => 'direction',
    is  => 'rw',
    default => 'vertical',
);

no Moose;

1;
