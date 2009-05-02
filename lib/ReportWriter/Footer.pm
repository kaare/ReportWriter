package ReportWriter::Footer;

use 5.010;
use Moose;
use MooseX::AttributeHelpers;

has 'containers' => (
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
