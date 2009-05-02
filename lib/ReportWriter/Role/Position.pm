package ReportWriter::Role::Position;

use Moose::Role;
use ReportWriter::Types;

has 'startx' => (
    isa     => 'Num',
    is      => 'rw',
    default => 0,
);
has 'starty' => (
    isa     => 'Num',
    is      => 'rw',
    default => 0,
);
has 'width' => (
    isa     => 'Num',
    is      => 'rw',
    default => 0,
);
has 'height' => (
    isa     => 'Num',
    is      => 'rw',
    default => 0,
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

=head2 cstartx

Return converted startx

Returns startx * conversion if unit is set 

Returns startx if unit is not set 

=cut

sub cstartx {
    my $self = shift;
    return $self->has_unit ? $self->startx * $self->conversion : $self->startx;
}

=head2 cstarty

Return converted starty

Returns starty * conversion if unit is set 

Returns starty if unit is not set 

=cut

sub cstarty {
    my $self = shift;
    return $self->has_unit ? $self->starty * $self->conversion : $self->starty;
}

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

no Moose::Role;

1;
