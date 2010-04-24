package ReportWriter::Output::Role::PDF;

use 5.010;
use Moose::Role;
use ReportWriter::Output::Report::PDF;

has 'pdf' => (
    isa => 'ReportWriter::Output::Report::PDF',
    is  => 'ro',
    builder => '_build_pdf',
    lazy => 1,
);

with qw(
    ReportWriter::Output::Role::Translations
    ReportWriter::Output::Role::Totals
    ReportWriter::Output::Role::Page
);

# Reverse the page direction
# Attribute is ro, so there can be no $ypos as parameter
# But why can't it be an after modifier, why won't it allow return values?
around 'ypos' => sub {
    my ($orig, $self, $ypos) = @_;
    $ypos = $self->$orig();
    return unless $ypos;
    my $paperheight = $self->report->page->height;
    return $paperheight - $ypos;
};

sub _build_pdf {
    my $self = shift;
    # Set unit for report
    return ReportWriter::Output::Report::PDF->new(
        filename        => $self->filename,
        PageSize        => $self->report->papername,
        PageOrientation => $self->report->orientation,
    );
}

after 'reportrow' => sub {
    my ( $self, $row, $reportrow ) = @_;
    $self->increment_ypos($reportrow->height); ## Unless the actual report implementation has written more rows. We need to solve that question
};

sub out_text {
    my ( $self, $text, $config ) = @_;
    return unless defined $text;
    #    my $trans = $self->{outclass}->{translation}; ## Translation as role
    #    $text = $trans->text($text);

## This ought really only be functions. We need to pass the right param at the right time!
    #    my $res = eval "$text"; ## Function evaluation as role
    #    $text = $res if $res and !$@;

    my $pdf = $self->pdf;
    $pdf->set_font($config->fontface);
    $pdf->size($config->fontsize);

    my $startx = $config->align eq 'right' ? $config->startx + $config->width : $config->startx;
## Refactor PDF Report API
# Calculate height as ypos - page end
# lead is row height
##
    my ($new_xpos, $new_ypos) = $pdf->add_paragraph($text, $startx, $self->ypos, $config->width, $config->height, 0, $config->height, $config->align);

=pod
 Here we have to decide if add_paragraph writes more than one row. Or else we have 
 to take care of it ourselves.
 
 Also, there's the issue if the page fills up here.
 It should be possible to fill up the page and put the spillover text on next page.
=cut
    #    $self->{new_ypos} = $new_ypos if $new_ypos < $self->{new_ypos}; ## What is this?

    return;
}

sub page {
    my ($self) = @_;
    $self->pdf->new_page;
    return;
}

sub header {
    my ( $self ) = @_;
#    return unless $self->report->header;
    my $header = $self->report->header;
    $self->container($_) for @{$header->containers};
    return;
}

sub body {
    my ( $self ) = @_;

    my $body = $self->report->body;

    $self->drawbox($body);
    $self->container($_) for @{$body->header};
#    $self->set_ypos($body->starty);
    $self->increment_ypos($_->height) for @{$body->header};
    return;
}

sub footer{
    my ( $self ) = @_;
    my $footer = $self->report->footer;
    $self->container($_) for @{$footer->containers};
    return;
}

sub page_images {
    my ($self) = @_;

    for my $image (@{ $self->report->images }) {
        $self->set_ypos($image->starty);
        my $filename = join '/', $self->root, $image->filename;
        $self->pdf->add_img($filename, $image->startx, $self->ypos, $image->scale);
    }

    return;
}

sub page_graphics {
    my ($self) = @_;

    for my $box (@{ $self->report->boxes }) {
        $self->pdf->draw_rect($box->startx, $box->starty, $box->startx + $box->width, $box->starty + $box->height);
    }

    return;
}

sub container {
    my ( $self, $container ) = @_;
    $self->drawbox($container);
    $self->field($_) for @{$container->fields};
    return;
}

sub drawbox {
    my ( $self, $box ) = @_;
    my $pdf = $self->pdf;
    $self->set_ypos($box->starty);
    my $starty = $self->ypos;
    $self->set_ypos($box->starty + $box->height);
    my $endy   = $self->ypos;
    $pdf->draw_rect($box->startx, $starty, $box->startx + $box->width, $endy) if defined $box->boxed;
    return;
}

sub field {
    my ( $self, $field ) = @_;

    return unless $field->result;
    #    $self->{xpos} = 0; ## Or where header starts
    #    for my $header (@{ $headers }) {
    #        $self->{ypos} = $header->{vstart};
    #        $self->column($header->{local} || $header->{text}, $header);
    #    }
    $self->set_ypos($field->starty);
    $self->out_text($field->result, $field);
    return;
}

sub result {
    my ($self) = @_;

    $self->finish_page;
    return $self->pdf->finish_report('none');
}

no Moose::Role;

1;
