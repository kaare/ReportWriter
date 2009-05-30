package ReportWriter::Output::Role::Page;

use 5.010;
use Moose::Role;

has 'ypos' => (
    isa => 'Num',
    is  => 'ro',
    default => 0,
);

use Data::Dumper; ##

before 'reportrow' => sub {
    my ( $self, $row ) = @_;
    $self->page unless $self->ypos;
};

after 'reportrow' => sub {
    my ( $self, $row, $reportrow ) = @_;
    $self->check_page;
};

after 'page' => sub {
    my ($self) = @_;
    $self->header;
    $self->page_images;
    $self->page_graphics;
    $self->body;
    return;
};

sub set_ypos {
    my ($self, $ypos) = @_;
    $self->{ypos} = $ypos;
    return $self->{ypos};
}

sub increment_ypos {
    my ($self, $ypos) = @_;
    $self->{ypos} += $ypos;
    return $self->{ypos};
}

sub column {
    my ($self, $value, $column) = @_;
    $self->out_text($value, $column);
}

sub check_page {
    my ($self) = @_;
    $self->page if $self->ypos < $self->report->page->height - ($self->report->body->starty + $self->report->body->height);
    return;
}

## obsolete. remove when body invocation is in place
sub headers {
    my ($self) = @_;

    $self->header($_) for @{ $self->report->header->containers };
## body related issues should be in their own method(_modifyer)
#    $self->begin_body($self->{outclass}->{body}); ## Either do as after 'headers' or as before 'body'
#    $self->body_header($self->{outclass}->{body}->{header}->{$_}) for keys %{ $self->{outclass}->{body}->{header} };

    return;
}

sub footers {
    my ($self) = @_;
    ##
    $self->footer($self->{outclass}->{page}->{footer}->{$_}) for keys %{ $self->{outclass}->{page}->{footer} };

    return;
}

no Moose::Role;

1;