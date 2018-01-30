package ReportWriter::Body;

use 5.010;
use Moose;
use ReportWriter::Types;

with 'ReportWriter::Role::Position';

has 'boxed' => (
    isa     => 'boxtype',
    is      => 'rw',
);
has 'header' => (
    traits => ['Array'],
    is        => 'ro',
    isa       => 'ArrayRef[ReportWriter::Container]',
    default   => sub { [] },
    handles  => {
        add_containers      => 'push',
        remove_last_container => 'pop',
    }
);

no Moose;

1;
