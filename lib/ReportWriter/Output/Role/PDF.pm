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

    $self->report->page->unit($self->report->unit) if $self->report->unit;
    my $paperheight = $self->report->page->cheight;
    return $paperheight - $ypos;
};

sub _build_pdf {
    my $self = shift;

    # Set unit for report
    $self->report->unit('pt') unless $self->report->has_unit;

    my $papername   = 'A4';          ## This should really be a report setting
    my $orientation = 'Portrait';    ## ditto
    return ReportWriter::Output::Report::PDF->new(
        filename        => $self->filename,
        PageSize        => $papername,
        PageOrientation => $orientation,
    );
}

after 'reportrow' => sub {
    my ( $self, $row, $reportrow ) = @_;

    # Perhaps a better way is to only total columns from a config parameter
    # or check if column is a number in some way
    #    my $trans = $self->{outclass}->{translation};  ## Translation as a role
    #    $trans->total_var($_, $rec->{$_}) for keys %{ $rec }; ## Totalling as a role
    $self->increment_ypos($reportrow->height); ## Unless the actual report implementation has written more rows. We need to solve that question
};

after 'page' => sub {
    my ($self) = @_;
## We need to rethink the translation issue
    # in the case of page totals we'd like to keep variable names somewhere.
    # But is Translations the correct place?
    # Even more, this bit of code looks like it should go into Page.pm, not PDF
    #    my $trans = $self->{outclass}->{translation}; ## Translation as role
    #    $trans->next_page;
    #    $trans->new_var($_->{name}) for @{ $self->{config} };

    $self->header;
    $self->page_images;
    $self->page_graphics;
    $self->body;

    return;
};

sub out_text {
    my ( $self, $text, $config ) = @_;

    return unless defined $text;
    #    my $trans = $self->{outclass}->{translation}; ## Translation as role
    #    $text = $trans->text($text);

## This ought really only be functions. We need to pass the right param at the right time!
    #    my $res = eval "$text"; ## Function evaluation as role
    #    $text = $res if $res and !$@;

## Do actual PDF writing later
    my $pdf = $self->pdf;
    $pdf->set_font($config->fontface);
    $pdf->size($config->fontsize);
    $config->unit($self->report->unit);
    my $linespace = $config->cheight;
    my ($new_xpos, $new_ypos) = $pdf->add_paragraph($text, $config->cstartx, $self->ypos, $config->cwidth, $config->cheight, 0, $linespace, $config->align);

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

    my $header = $self->report->header;
    $self->container($_) for @{$header->containers};
    return;
}

sub body {
    my ( $self ) = @_;

    my $body = $self->report->body;

    my $pdf = $self->pdf;
    $body->unit($self->report->unit);
    $self->set_ypos($body->cstarty);
    my $starty = $self->ypos;
    $self->set_ypos($body->cstarty + $body->cheight);
    my $endy   = $self->ypos;
    $pdf->draw_rect($body->cstartx, $starty, $body->cstartx + $body->cwidth, $endy) if defined $body->boxed;

    $self->container($_) for @{$body->header};
    $self->set_ypos($body->cstarty);
    $self->increment_ypos($_->height) for @{$body->header};
    return;
}

sub page_images {
    my ($self) = @_;

    for my $image (@{ $self->report->images }) {
        $image->unit($self->report->unit);
        my $filename = join '/', $self->root, $image->filename;
        $self->pdf->add_img($filename, $image->cstartx, $self->ypos($image->cstarty), $image->scale);
    }

    return;
}

sub page_graphics {
    my ($self) = @_;

    for my $box (@{ $self->report->boxes }) {
        $box->unit($self->report->unit);
        $self->pdf->draw_rect($box->cstartx, $box->cstarty, $box->cstartx + $box->width, $box->cstarty + $box->cheight);
    }

    return;
}

sub container {
    my ( $self, $container ) = @_;

    $self->field($_) for @{$container->fields};
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
    $field->unit($self->report->unit);
    $self->set_ypos($field->cstarty);
    $self->out_text($field->result, $field);
    return;
}

sub result {
    my ($self) = @_;

    return $self->pdf->finish_report('none');
}

no Moose::Role;

1;
