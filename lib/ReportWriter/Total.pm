package ReportWriter::Total;

use 5.010;
use Moose;

has 'name' => (
    isa => 'Str',
    is  => 'rw',
);
has 'height' => (
    isa     => 'Num',
    is      => 'ro',
    default => 0,
);
has 'columns' => (
    traits => ['Array'],
    is        => 'ro',
    isa       => 'ArrayRef[ReportWriter::Column]',
    default   => sub { [] },
    handles  => {
        add_columns      => 'push',
        remove_last_column => 'pop',
    }
);

after 'add_columns' => sub {
    my ( $self, @columns ) = @_;

    for my $column (@columns) {
        ## The problem is that we may not have the correct height of the total column.
        # This approach copies the height of the row column itself, not the total column.
        # Of course, user can always just enter a value
        $self->{height} = $column->height if $column->height > $self->height;
    }
};

no Moose;

1;
