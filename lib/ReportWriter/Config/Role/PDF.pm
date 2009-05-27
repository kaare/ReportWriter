package ReportWriter::Config::Role::PDF;

use 5.010;
use Moose::Role;

with 'ReportWriter::Config::Role::Page';

=pod

PDF related config stuff here

- sizes, positions, etc

=cut

around '_containerfield' => sub {
    my ($orig, $self, $field, $container, $startx, $starty) = @_;

    # Provide some reasonable defaults for PDF
    $field->{fontface} ||= 'Helvetica';
    $field->{fontsize} ||= 10;
    $field->{height}   ||= $field->{fontsize} * 1.2;
    $field->{width}    ||= 50;
    return $self->$orig($field, $container, $startx, $starty);
};

no Moose::Role;

1;
