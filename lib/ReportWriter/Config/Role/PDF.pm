package ReportWriter::Config::Role::PDF;

use 5.010;
use Moose::Role;

has 'defaultfield' => (
    isa => 'ReportWriter::Field',
    is  => 'rw',
);

# Some default constants
use constant FONTFACE => 'Helvetica';
use constant FONTSIZE => 10;
use constant LEAD     => 1.2;
use constant WIDTH    => 50;
use constant SPACING  => 4;

with 'ReportWriter::Config::Role::Page';

=pod

PDF related config stuff here

- sizes, positions, etc

=cut

before '_containerfield' => sub {
    my ($self, $field, $container, $startx, $starty) = @_;

    # Provide some reasonable defaults for PDF
    $field->{fontface} ||= $self->defaultfield->fontface || FONTFACE;
    $field->{fontsize} ||= $self->defaultfield->fontsize ||FONTSIZE;
    $field->{height}   ||= $field->{fontsize} * LEAD;
    $field->{width}    ||= $self->defaultfield->width || WIDTH;
    $field->{width}     *= $self->conversion;
};

around '_column' => sub {
    my ($orig, $self, $column) = @_;

#    # Provide some reasonable defaults for PDF
## Columns don't have individual height; rows have
    $column->{width} *= $self->conversion;
    my $col = $self->$orig($column);
    $col->fontface($self->defaultfield->fontface ? $self->defaultfield->fontface : FONTFACE);
    $col->fontsize($self->defaultfield->fontsize ? $self->defaultfield->fontsize : FONTSIZE);
    $col->height($col->fontsize * LEAD);

    return $col;
};

before '_images' => sub {
    my ( $self, $config ) = @_;
    return undef unless $config->{images};

    map {$_->{startx} *= $self->conversion;$_->{starty} *= $self->conversion;} @{ $config->{images} };
};

before '_do_config' => sub {
    my ($self, $cfg) = @_;
    $self->defaultfield(ReportWriter::Field->new);
};

around '_container' => sub {
    my ( $orig, $self, $config ) = @_;
    if ($config->{font}) {
        $self->defaultfield->fontface($config->{font}{face});
        $self->defaultfield->fontsize($config->{font}{size});
    }
    $self->defaultfield->width($config->{width}) if $config->{width};
    $self->defaultfield->height($config->{height}) if $config->{height};
    my $reportcontainer = $self->$orig($config);
    my $displacement = $reportcontainer->height + SPACING;
    $reportcontainer->height($reportcontainer->height + SPACING * 2);
    $reportcontainer->starty($reportcontainer->starty-$displacement);
    return $reportcontainer;
};

before '_body' => sub {
    my ( $self, $config ) = @_;
    if ($config->{body}{font}) {
        $self->defaultfield->fontface($config->{body}{font}{face});
        $self->defaultfield->fontsize($config->{body}{font}{size});
    }
    $config->{body}{startx} *= $self->conversion;
    $config->{body}{starty} *= $self->conversion;
    $config->{body}{width}  *= $self->conversion;
    $config->{body}{height} *= $self->conversion;
};

before '_header' => sub {
    my ( $self, $config ) = @_;
    for my $key (keys %{$config->{header} }) {
        $config->{header}{$key}{startx} *= $self->conversion;
        $config->{header}{$key}{starty} *= $self->conversion;
#        $config->{header}{$key}{width}  *= $self->conversion;
#        $config->{header}{$key}{height} *= $self->conversion;
    }
};

before '_footer' => sub {
    my ( $self, $config ) = @_;
    for my $key (keys %{$config->{footer} }) {
        $config->{footer}{$key}{startx} *= $self->conversion;
        $config->{footer}{$key}{starty} *= $self->conversion;
    }
};

after '_page' => sub {
    my ($self, $config) = @_;
    $self->report->page->width($self->report->page->width * $self->conversion);
    $self->report->page->height($self->report->page->height * $self->conversion);
};

no Moose::Role;

1;
