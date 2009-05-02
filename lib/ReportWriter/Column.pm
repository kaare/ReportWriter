package ReportWriter::Column;

use 5.010;
use Moose;

extends 'ReportWriter::Field';

has 'startx' => (
    isa => 'Num',
    is  => 'rw',
);
has 'endx' => (
    isa => 'Num',
    is  => 'rw',
);

=head2 cstartx

Return converted startx

Returns startx * conversion if unit is set 

Returns startx if unit is not set 

=cut

sub cstartx {
    my $self = shift;
    return $self->has_unit ? $self->startx * $self->conversion : $self->startx;
}

=head2 cendx

Return converted endx

Returns endx * conversion if unit is set 

Returns endx if unit is not set 

=cut

sub cendx {
    my $self = shift;
    return $self->has_unit ? $self->endx * $self->conversion : $self->endx;
}

no Moose;

1;
