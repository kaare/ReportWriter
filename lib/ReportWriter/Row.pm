package ReportWriter::Row;

use 5.010;
use Moose;
use MooseX::AttributeHelpers;

has 'name' => (
    isa => 'Str',
    is  => 'rw',
);
has 'startx' => (
    isa     => 'Num',
    is      => 'ro',
    default => 0,
);
has 'width' => (
    isa     => 'Num',
    is      => 'ro',
    default => 0,
);
has 'height' => (
    isa     => 'Num',
    is      => 'ro',
    default => 0,
);
has 'columns' => (
    metaclass => 'Collection::Array',
    is        => 'ro',
    isa       => 'ArrayRef[ReportWriter::Column]',
    default   => sub { [] },
    provides  => {
        'push' => 'add_columns',
        'pop'  => 'remove_last_column',
    }
);

after 'add_columns' => sub {
    my ( $self, @columns ) = @_;

    # Do what's necessary to make a column work in a row environment
    # i.e. tell it where to start, end etc.
    $self->{width} = $self->startx;
    for my $column (@columns) {
        $column->startx( $self->width );
        $column->endx( $column->startx + $column->width );
        $self->{height} = $column->height if $column->height > $self->height;
        $self->{width} += $column->width;
    }
};

no Moose;

1;
