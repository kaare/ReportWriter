package ReportWriter::Output;

use 5.010;
use Moose;
use Moose::Util::TypeConstraints;

enum 'output_type' => qw(Array Text PDF);

no Moose::Util::TypeConstraints;

has 'type' => (
    isa => 'output_type',
    is => 'rw',
);
has 'report' => (
    isa => 'ReportWriter::Report',
    is  => 'rw',
);
has 'filename' => (
    isa => 'Str',
    is => 'rw',
);

use Data::Dumper;##

sub BUILD {
    my $self = shift;
say "type", $self->type;
    with 'ReportWriter::Output::Role::' . $self->type;
}

=head2 row

Call this method with a hashref containing the row of data

=cut
sub row {
    my ($self, $row) = @_;
    $self->reportrow($row, $_) for @{ $self->report->rows };
}

sub reportrow {
    my ($self, $row, $reportrow) = @_;
    $self->column($row->{$_->name}, $_) for @{ $reportrow->columns };
}

#sub result { ## Can we require this from the output role?
#    my ($self, $row) = @_;
#}

no Moose;

1;
