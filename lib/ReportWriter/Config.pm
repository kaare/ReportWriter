package ReportWriter::Config;

use 5.010;
use Moose;
use File::ShareDir qw/dist_dir/;
use Hash::Merge qw/merge/;
use YAML::Tiny;
use Paper::Specs;

use ReportWriter::Body;
use ReportWriter::Box;
use ReportWriter::Column;
use ReportWriter::Container;
use ReportWriter::Containerfield;
use ReportWriter::Field;
use ReportWriter::Footer;
use ReportWriter::Header;
use ReportWriter::Image;
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
        return -d 'share/layout/' ? 'share/layout/' : dist_dir('ReportWriter') . '/layout';
    },
    lazy => 1,
);

sub BUILD {
    my $self = shift;

    with 'ReportWriter::Config::Role::' . 'PDF';##$self->type;
    __PACKAGE__->meta->make_immutable();

    my $cfg = $self->_read_config( $self->config );
    $self->_do_config($cfg);
}

=head2 _read_config

Find yml in local dir first, then dist dir

=cut

sub _read_config {
    my ( $self, $filename, @processed ) = @_;

    my $yaml = YAML::Tiny->read($filename) || YAML::Tiny->read( $self->layoutdir . '/' . $filename );
    push @processed, $filename;
    my $config = $yaml->[0];
    $config = merge( $config, $self->_read_config( $config->{layout}, @processed ) )
        if defined $config->{layout} and grep { $_ ne $config->{layout} } @processed;

    return $config;
}

sub _do_config {
    my ($self, $cfg) = @_;

    $self->report( ReportWriter::Report->new );
    $self->_rows($cfg);
    $self->_totals($cfg);
    $self->_images($cfg);
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
        my $reporttotal = ReportWriter::Total->new(_params($total, qw/name height/) );
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
use Data::Dumper;
say STDERR Dumper $row;
## This works for page (body) type reports only ##
        $row->{startx} ||= $config->{body}{startx};
        $row->{starty} ||= $config->{body}{starty};
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

    return ReportWriter::Column->new(_params($column, qw/name width align text/) );
}

=head2 _image

Images

=cut

sub _images {
    my ( $self, $config ) = @_;

    return undef unless $config->{images};

    for my $image ( @{ $config->{images} } ) {
        my $reportimage = ReportWriter::Image->new( _params($image, qw/startx starty width height scale filename/) );
        $self->report->add_images($reportimage);
    }

    return;
}

=head2 _box

Box

=cut

sub _boxes {
    my ( $self, $config ) = @_;

    return undef unless $config->{boxes};

    for my $box ( @{ $config->{boxes} } ) {
        my $reportbox = ReportWriter::Box->new( _params($box, qw/startx starty width height fill type thickness/) );
        $self->report->add_boxes($reportbox);
    }

    return;
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
