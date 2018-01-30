package ReportWriter::Container;

use 5.010;
use Moose;
use ReportWriter::Types;

with 'ReportWriter::Role::Position';

has 'boxed' => (
    isa     => 'boxtype',
    is      => 'rw',
);
has 'spacing' => (
    isa     => 'Num',
    is      => 'rw',
    default => 0,
);
has 'padding' => (
    isa     => 'Num',
    is      => 'rw',
    default => 10,
);
has 'fields' => (
    traits => [ 'Array' ],
    is        => 'ro',
    isa       => 'ArrayRef[ReportWriter::Containerfield]',
    default   => sub { [] },
    handles  => {
        add_fields      => 'push',
        remove_last_field => 'pop',
    }
);
has 'direction' => (
    isa => 'direction',
    is  => 'rw',
    default => 'vertical',
);

after 'add_fields' => sub {
    my ( $self, @fields ) = @_;

    if ( $self->direction eq 'horizontal' ) {
        for my $field (@fields) {
            $self->{height} = $field->height if $field->height > $self->height;
            $self->{width} += $field->width;
        }
    } else {
        for my $field (@fields) {
            $self->{height} += $field->height;
            $self->{width} = $field->width if $field->width > $self->width;
        }
    }
};

no Moose;

1;
