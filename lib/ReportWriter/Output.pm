package ReportWriter::Output;

use 5.010;
use Moose;
use ReportWriter::Types;

with 'MooseX::Traits';

has 'filename' => (
    isa => 'Str',
    is  => 'rw',
);
has 'root' => (
    isa     => 'Str',
    is      => 'rw',
    default => '.',
    lazy    => 1,
);
has 'type' => (
    isa => 'report_type',
    is  => 'rw',
);
has 'report' => (
    isa => 'ReportWriter::Report',
    is  => 'rw',
);

=head2 row

Call this method with a hashref containing the row of data

=cut

sub row {
    my ( $self, $rowdata ) = @_;
    $self->reportrow( $rowdata, $_ ) for @{ $self->report->rows };
}

sub reportrow {
    my ( $self, $rowdata, $reportrow ) = @_;
    $self->column( $rowdata->{ $_->name }, $_ ) for @{ $reportrow->columns };
}

#sub result { ## Can we require this from the output role?
#    my ($self, $row) = @_;
#}

no Moose;

1;
