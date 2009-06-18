package ReportWriter::Container;

use 5.010;
use Moose;
use MooseX::AttributeHelpers;
use ReportWriter::Types;

with 'ReportWriter::Role::Position';
has 'boxed' => (
    isa     => 'boxtype',
    is      => 'rw',
);
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

after 'add_fields' => sub {
    my ( $self, @fields ) = @_;

    if ( $self->direction eq 'horizontal' ) {
        for my $field (@fields) {
use Data::Dumper;
say STDERR Dumper $field;
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
