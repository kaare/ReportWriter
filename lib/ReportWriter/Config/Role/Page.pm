package ReportWriter::Config::Role::Page;

use 5.010;
use Moose::Role;

=pod

Page related config stuff here

- page, header, footer, etc

=cut

after '_do_config' => sub {
    my ($self, $cfg) = @_;

    if ( my $page = $cfg->{page} ) {
        $self->_page($page);
        $self->_header($page);
        $self->_footer($page);
    }
    $self->_body($cfg);
##
    # use Data::Dumper;
    # say STDERR Dumper $cfg, $self->report;
##
};

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

    my $reportcontainer = ReportWriter::Container->new(  _params($container, qw/direction startx starty width height align/) );
    my ($startx, $starty) = ($reportcontainer->startx, $reportcontainer->starty);
    $reportcontainer->add_fields( map { $self->_containerfield($_, $reportcontainer, \$startx, \$starty) } @{ $container->{fields} } );
    return $reportcontainer;
}

=head2 _containerfield

Parameters are containerfield, direction and scalar references to startx and starty

Warning! startx and starty are being modified here

=cut

sub _containerfield {
    my ( $self, $field, $container, $startx, $starty ) = @_;

    my %params = _params($field, qw/label fontface fontsize align text width/);
    $params{direction} ||= $container->direction;
    $params{width} ||= $container->width;
    $params{startx} = $$startx;
    $params{starty} = $$starty;
    my $containerfield = ReportWriter::Containerfield->new( %params );
    if ($params{direction} eq 'vertical') {
        $$starty += $field->{height} // 12;
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
    my $reportbody = ReportWriter::Body->new(_params($body, qw/startx starty width height boxed/) );

    # Body headers
    $reportbody->add_containers( map {$self->_bodyheader($_, $body, $config) } values %{ $body->{header} } );
    $self->report->body($reportbody);
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
    my ( $self, $header, $body, $config ) = @_;

    my $slice;
    @{ $header}{qw/startx starty width/} = @{ $body}{qw/startx starty width/};
    $header->{height} = 12; ## Find some meaningful value, plz ##
    $header->{direction} = 'horizontal';
    # Header labels points to the wanted row
    my ($row) = grep {$_->{name} eq $header->{labels}} @{ $config->{rows} };
    my @fields = map { { fontface => $header->{font}{face}, fontsize => $header->{font}{size}, text => $_->{label}, width => $_->{width}, align => $_->{align} } } @{ $row->{columns} };
    $header->{fields} = [ @fields ]; 
    return $self->_container($header)
}

=head2 _params

Takes a config hashref and a list of names and returns a hash with the defined values

=cut

sub _params {
    my ($hashref, @names) = @_;
    return map { $_ => $hashref->{$_} } grep {defined $hashref->{$_}} @names;
}

no Moose::Role;

1;
