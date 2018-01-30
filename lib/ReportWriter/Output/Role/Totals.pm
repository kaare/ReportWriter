package ReportWriter::Output::Role::Totals;

use 5.010;
use Moose::Role;

has 'breaks' => (
    traits    => [ 'Hash' ],
    is        => 'rw',
    isa       => 'HashRef[HashRef]',
    default   => sub { {} },
    handles  => {
        exists_in_breaks => 'exists',
        ids_in_breaks  => 'keys',
        get_break      => 'get',
        set_break      => 'set',
    },
    lazy => 1,
);

after 'column' => sub {
    my ( $self, $value, $column ) = @_;
    my $configs = $self->report->totals;

    for my $config (@$configs) {
        my @column_names = map {$_->name} @{ $config->columns };
        if (@column_names ~~ $column->name) {
            my $break = $self->get_break($config->name);
            $self->set_break($config->name, _set_break_values($break, 'totals', $column->name, $value));
            $self->set_break($config->name, _set_break_values($break, 'page', $column->name, $value));
        }
    }
};

before 'row' => sub {
    my ( $self, $row ) = @_;
    my $configs = $self->report->totals;
    for my $config (@$configs) {
        my $break = $self->get_break($config->name);
        if (defined $break->{value} and $break->{value} ne $row->{$config->name}) {
            $self->total_row($config);
            $self->set_break($config->name, _clear_break_values($break, 'totals'));
        }
        $break->{value} = $row->{$config->name};
        $break->{count} = defined($break->{count}) ? $break->{count} + 1 : 1;
        $self->set_break($config->name, $break);
    }
};

after 'page' => sub {
    my ( $self ) = @_;
    my $configs = $self->report->totals;
    for my $config (@$configs) {
        my $break = $self->get_break($config->name);
            $self->set_break($config->name, _clear_break_values($break, 'page'));
    }
};

sub total_row {
    my ($self, $config) = @_;
    my $break = $self->get_break($config->name);
    $self->total_column($_, $break->{totals}{$_}, $config) for keys %{ $break->{totals} };
    $self->increment_ypos($config->height);
}

sub total_column {
    my ($self, $col_name, $value, $config) = @_;
    return unless $value;

    my ($column) = grep {$_->name eq $col_name} @{ $config->columns };
    $self->out_text($value, $column);
}

=head2 _set_break_values

Break values keep track of

Totals for each totalling group

Count of rows totalled

=cut

sub _set_break_values {
    my ($break, $group, $name, $value) = @_;
    my $totals = $break->{$group} // {};
    my $total = defined($totals->{$name}) ? $totals->{$name} + $value : $value;
    $totals->{$name} = $total;
    $break->{$group} = $totals;
    return $break;
}

sub _clear_break_values {
    my ($break, $group) = @_;
    my $totals = $break->{totals} // {};
    $totals->{$_} = 0 for keys %{ $break->{$group} };
    $break->{$group} = $totals;
    $break->{count} = 0;
    return $break;
}

no Moose::Role;

1;
