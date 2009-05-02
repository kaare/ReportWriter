package ReportWriter::Config;

use 5.010;
use Moose;
use File::ShareDir qw/dist_dir/;
use Hash::Merge qw/merge/;
use YAML::Tiny;
use Paper::Specs;

use ReportWriter::Body;
use ReportWriter::Column;
use ReportWriter::Container;
use ReportWriter::Containerfield;
use ReportWriter::Field;
use ReportWriter::Footer;
use ReportWriter::Header;
use ReportWriter::Page;
use ReportWriter::Report;
use ReportWriter::Row;
use ReportWriter::Total;

has 'config' => (
    isa => 'Str',
    is  => 'rw',
);
has 'report' => (
    isa => 'ReportWriter::Report',
    is  => 'rw',
);
has 'layoutdir' => (
    isa     => 'Str',
    is      => 'rw',
    default => sub {
        return -d 'share/layout/' ? 'share/layout/' : dist_dir('Document-ReportWriter') . '/layout';
    },
    lazy => 1,
);

__PACKAGE__->meta->make_immutable();

sub BUILD {
    my $self = shift;

    my $cfg = $self->_config( $self->config );
    $self->report( ReportWriter::Report->new );
    $self->_rows($cfg);
    $self->_totals($cfg);
    if ( my $page = $cfg->{page} ) {
        $self->_page($page);
        $self->_header($page);
        $self->_footer($page);
    }
    $self->_body($cfg);

##
    #    use Data::Dumper;
    #    say STDERR Dumper $cfg, $self->report;
##
}

=head2 _config

Find yml in local dir first, then dist dir

=cut

sub _config {
    my ( $self, $filename, @processed ) = @_;

    my $yaml = YAML::Tiny->read($filename) || YAML::Tiny->read( $self->layoutdir . '/' . $filename );
    push @processed, $filename;
    my $config = $yaml->[0];
    $config = merge( $config, $self->_config( $config->{layout}, @processed ) )
        if defined $config->{layout} and grep { $_ ne $config->{layout} } @processed;

    return $config;
}

=head2 _totals

Value, count and totals for each column initiated

Config copied from body columns

=cut

sub _totals {
    my ( $self, $config ) = @_;

    return undef unless $config->{totals};

    for my $total ( @{ $config->{totals} } ) {
        my @columns;
        for my $row ( @{ $self->report->rows } ) {
            push @columns, grep {@{ $total->{column_names} } ~~ $_->name } @{ $row->columns };
        }
        my $reporttotal = ReportWriter::Total->new(_params($total, qw/name/) );
        $reporttotal->add_columns(@columns);
        $self->report->add_totals($reporttotal);
    }
}

=head2 _rows

Rows

=cut

sub _rows {
    my ( $self, $config ) = @_;

    return undef unless $config->{rows};

    for my $row ( @{ $config->{rows} } ) {
        my $reportrow = ReportWriter::Row->new( _params($row, qw/name/) );
        $reportrow->add_columns( map { $self->_column($_) } @{ $row->{columns} } );
        $self->report->add_rows($reportrow);
    }

=pod
    $self->{row}->{height} = 0;
    undef $self->{row}->{startx};
    $self->{row}->{endx}  = 0;
    $self->{row}->{width} = 0;

    $self->{row}->{startx} *= $self->{unit};
    $self->{row}->{width}  *= $self->{unit};

    return $columns;
=cut

    return;
}

=head2 _column

Handle each column. Also figure out what the row height is

=cut

sub _column {
    my ( $self, $column ) = @_;

=pod
    $column = ref $column ? $column : { name => $column };
    $column->{start} ||= $self->{row}->{endx};
    ## Calculate width from next column start or paper width if not defined. Or set to standard 25
    $column->{width}  ||= 25;
    $column->{height} ||= 13;    ## For testing :PDF

    # row data
    my $endx = $column->{start} + $column->{width};
    $self->{row}->{startx} = $column->{start} if !defined $self->{row}->{startx} or $self->{row}->{startx} > $column->{start};
    $self->{row}->{width} += $column->{width};
    $self->{row}->{endx} = $endx if $self->{row}->{endx} < $endx;

    $column->{start} *= $self->{unit};
    $column->{width} = $column->{width} * $self->{unit} if $column->{width} and $self->{unit};
=cut

    return ReportWriter::Column->new(_params($column, qw/name width/) );
}

=head2 _page

Headers

=cut

sub _page {
    my ( $self, $config ) = @_;

    my ( $width, $height ) = $self->pagesize( $config->{format} );
    my $reportpage = ReportWriter::Page->new( width => $width, height => $height );
    $self->report->page($reportpage);

    return;
}

sub pagesize {
    my ( $self, $name ) = @_;

    Paper::Specs->units('mm');
    my $page = Paper::Specs->find( code => $name ) || Paper::Specs->find( code => 'A4' );

    return $page->sheet_size;
}

=head2 _header

Headers

=cut

sub _header {
    my ( $self, $config ) = @_;

    return undef unless $config->{header};

    my $reportheader = ReportWriter::Header->new;
    $reportheader->add_containers( map { $self->_container($_) } values %{ $config->{header} } );
    $self->report->header($reportheader);

    return;
}

=head2 _footer

Footers

=cut

sub _footer {
    my ( $self, $config ) = @_;

    return undef unless $config->{footer};

    my $reportfooter = ReportWriter::Footer->new;
    $reportfooter->add_containers( map { $self->_container($_) } values %{ $config->{footer} } );
    $self->report->footer($reportfooter);

    return;
}

=head2 _container


=cut

sub _container {
    my ( $self, $container ) = @_;

    my $reportcontainer = ReportWriter::Container->new(  _params($container, qw/direction startx starty width height/) );

    my ($direction, $startx, $starty) = ($reportcontainer->direction, $reportcontainer->startx, $reportcontainer->starty);
    $reportcontainer->add_fields( map { $self->_containerfield($_, $direction, \$startx, \$starty) } @{ $container->{fields} } );
    $reportcontainer->direction( $container->{direction} ) if $container->{direction};
    return $reportcontainer;
}

=head2 _containerfield

Parameters are containerfield, direction and scalar references to startx and starty

Warning! startx and starty are being modified here

=cut

sub _containerfield {
    my ( $self, $field, $direction, $startx, $starty ) = @_;

    my %params = _params($field, qw/label text width/);
    $params{startx} = $$startx;
    $params{starty} = $$starty;
    my $containerfield = ReportWriter::Containerfield->new( %params );

    if ($direction eq 'vertical') {
        $$starty += $field->{height} // 0;
    } else {
        $$startx += $field->{width} // 0;
    }
    return $containerfield;
}

=head2 _body

=cut

sub _body {
    my ( $self, $config ) = @_;

    return undef unless $config->{body};

    my $body = $config->{body};
    $self->report->body(
        ReportWriter::Body->new(_params($body, qw/startx starty width height/) )
    );

=pod
    $body->{start} = $self->page->{size}->{height} - $body->{start} * $self->{unit} if $body->{start} and $self->{unit}; # if defined we'll convert to right units
    $body->{start} ||= $self->page->{size}->{height} - $self->{headerpos} * $self->{unit} - $self->{height} if defined $self->{headerpos} and defined $self->{unit};
##    $body->{height} ||= papersize - headersize - footersize;
    $body->{height} = $body->{height} * $self->{unit} if $self->{unit};
    $body->{end}    = $body->{start} - $body->{height} if $body->{height};
    $body->{startx} *= $self->{unit} if $body->{startx};
    $body->{startx} = $self->{row}{startx};
    $body->{width}  *= $self->{unit} if $body->{width};
    $body->{width}  = $self->{row}{width};
    $body->{endx }  = $self->{row}{startx} + $self->{row}{width};
    for my $header (keys %{ $body->{header} }) {
        $body->{header}{$header}{row}     = clone($self->{row});
        $body->{header}{$header}{row}{height} = $body->{header}{$header}{font}{size}; ##
        $body->{header}{$header}{columns} = $self->_bodyheader($body->{header}{$header}, $body);
    }
    for my $footer (keys %{ $body->{footer} }) {
        $body->{footer}{$footer}{row}     = clone($self->{row});
        $body->{footer}{$footer}{row}{height} = $body->{footer}{$footer}{font}{size}; ##
    }

    return $body;
=cut

}

sub _bodyheader {
    my ( $self, $header, $body ) = @_;

    my @columns = @{ clone( $self->columns ) };
    return [ map { merge( shift @columns, $_ ) } @{ $header->{columns} } ];
}

=head2 _params

Takes a config hashref and a list of names and returns a hash with the defined values

=cut

sub _params {
    my ($hashref, @names) = @_;
    return map { $_ => $hashref->{$_} } grep {defined $hashref->{$_}} @names;
}

no Moose;

1;
