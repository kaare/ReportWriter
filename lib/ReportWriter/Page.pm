package ReportWriter::Page;

use 5.010;
use Moose;
use ReportWriter::Types;

has 'width' => (
    isa => 'Num',
    is  => 'rw',
);
has 'height' => (
    isa => 'Num',
    is  => 'rw',
);
has 'unit' => (
    isa       => 'unit',
    is        => 'rw',
    predicate => 'has_unit',
    trigger   => sub {
        my ( $self, $unit ) = @_;
        my %units = ( mm => 1, pt => 2.83464629 );
        $self->{conversion} = $units{$unit};
    },
);
has 'conversion' => (
    isa => 'Num',
    is  => 'ro',
);

=head2 cwidth

Return converted width

Returns width * conversion if unit is set 

Returns width if unit is not set 

=cut

sub cwidth {
    my $self = shift;
    return $self->has_unit ? $self->width * $self->conversion : $self->width;
}

=head2 cheight

Return converted height

Returns height * conversion if unit is set 

Returns height if unit is not set 

=cut

sub cheight {
    my $self = shift;
    return $self->has_unit ? $self->height * $self->conversion : $self->height;
}

no Moose;

1;
