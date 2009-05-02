package ReportWriter::Output::Role::Translations;

use 5.010;
use Moose::Role;
use String::Interpolate;

has 'template' => (
    isa     => 'String::Interpolate',
    is      => 'ro',
    builder => '_build_template',
    lazy    => 1,
);

our $pagenr = 0; ## Class attribute?

sub _build_template {
    my $self     = shift;
    my $template = String::Interpolate->new;
    $template->{PAGENR} ||= sub () { $pagenr };
    $template->{TIME} = sub () {localtime};
    $template->{ISODATE} = sub () { my @time = localtime; return join '-', $time[5] + 1900, $time[4] + 1, $time[3] };
    return $template;
}

before 'column' => sub {
    my ( $self, $value, $column ) = @_;
};

before 'field' => sub {
    my ( $self, $field ) = @_;
    my $text = $field->text;
};

before 'page' => sub {
    my ( $self, $page_data ) = @_;

    $pagenr++;
};

sub next_page {
    $pagenr++;
}

sub page_data {
    my ( $self, $page_data ) = @_;

    $self->template->{PAGE} = sub () { $page_data };
}

sub new_var {
    my ( $self, $name ) = @_;
    $self->template->{$name} = 0;
}

sub total_var {
    my ( $self, $name, $value ) = @_;
    $self->template->{VAR}{$name} += $value;
}

sub text {
    my ( $self, $text ) = @_;
    return scalar $self->template->($text);
}

no Moose::Role;

1;
