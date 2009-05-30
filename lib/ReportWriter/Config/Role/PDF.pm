package ReportWriter::Config::Role::PDF;

use 5.010;
use Moose::Role;

# Some default constants
use constant FONTFACE => 'Helvetica';
use constant FONTSIZE => 10;
use constant LEAD     => 1.2;
use constant WIDTH    => 50;

with 'ReportWriter::Config::Role::Page';

=pod

PDF related config stuff here

- sizes, positions, etc

=cut

around '_containerfield' => sub {
    my ($orig, $self, $field, $container, $startx, $starty) = @_;

    # Provide some reasonable defaults for PDF
    $field->{fontface} ||= FONTFACE;
    $field->{fontsize} ||= FONTSIZE;
    $field->{height}   ||= $field->{fontsize} * LEAD;
    $field->{width}    ||= WIDTH;
    $field->{width}     *= $self->conversion;
    return $self->$orig($field, $container, $startx, $starty);
};

around '_column' => sub {
    my ($orig, $self, $column) = @_;

#    # Provide some reasonable defaults for PDF
## Columns don't have individual height; rows have
    $column->{width} *= $self->conversion;
    my $col = $self->$orig($column);
    $col->fontface($self->defaultfield->fontface ? $self->defaultfield->fontface : FONTFACE);
    $col->fontsize($self->defaultfield->fontsize ? $self->defaultfield->fontsize: FONTSIZE);
    $col->height($col->fontsize * LEAD);

    return $col;
};

before '_body' => sub {
    my ( $self, $config ) = @_;
    $config->{body}{startx} *= $self->conversion;
    $config->{body}{starty} *= $self->conversion;
    $config->{body}{width}  *= $self->conversion;
    $config->{body}{height} *= $self->conversion;
};

after '_page' => sub {
    my ($self, $config) = @_;
    $self->report->page->width($self->report->page->width * $self->conversion);
    $self->report->page->height($self->report->page->height * $self->conversion);
};

no Moose::Role;

=head2 cheight

Return converted height

Returns height * conversion if unit is set 

Returns height if unit is not set 

=cut

sub cheight {
    my $self = shift;
    return $self->has_unit ? $self->height * $self->conversion : $self->height;
}

1;
