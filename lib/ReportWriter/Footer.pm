package ReportWriter::Footer;

use 5.010;
use Moose;

has 'containers' => (
    traits    => [ 'Array' ],
    is        => 'ro',
    isa       => 'ArrayRef[ReportWriter::Container]',
    default   => sub { [] },
    handles  => {
        add_containers        => 'push',
        remove_last_container => 'pop',
    }
);

no Moose;

1;
