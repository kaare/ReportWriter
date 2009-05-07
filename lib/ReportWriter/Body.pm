package ReportWriter::Body;

use 5.010;
use Moose;
use MooseX::AttributeHelpers;
use ReportWriter::Types;

with 'ReportWriter::Role::Position';

has 'boxed' => (
    isa     => 'boxtype',
    is      => 'rw',
    default => 'normal',
);
has 'header' => (
    metaclass => 'Collection::Array',
    is        => 'ro',
    isa       => 'ArrayRef[ReportWriter::Container]',
    default   => sub { [] },
    provides  => {
        'push' => 'add_containers',
        'pop'  => 'remove_last_container',
    }
);

no Moose;

1;
