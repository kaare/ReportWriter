package ReportWriter;

use 5.010;
use Moose;

use ReportWriter::Config;
use ReportWriter::Output;

our $VERSION   = '0.01';

has 'config_file' => (
    isa => 'Str',
    is  => 'ro',
);
has 'config' => (
    isa => 'Object',
    is  => 'ro',
	lazy    => 1,
	builder => '_build_config',
	init_arg   => undef,
);
has 'type' => (
    isa => 'report_type',
    is  => 'rw',
);
has 'filename' => (
    isa => 'Str',
    is  => 'ro',
);
has 'output' => (
    isa => 'Object',
    is  => 'ro',
	lazy    => 1,
	builder => '_build_output',
	init_arg   => undef,
);
has 'root' => (
    isa     => 'Str',
    is      => 'rw',
    default => sub {
        return -d 'share/etc/' ? 'share/' : dist_dir('ReportWriter');
    },
    lazy => 1,
);

sub _build_config {
	my $self = shift;
    my $role = 'ReportWriter::Config::Role::' . $self->type;
	$self->{config} = ReportWriter::Config->with_traits($role)->new(
		config => $self->config_file,
		type => $self->type,
		root => $self->root,
	);
}

sub _build_output {
	my $self = shift;
    my $role = 'ReportWriter::Output::Role::' . $self->type;
	$self->{output} = ReportWriter::Output->with_traits($role)->new(
		filename => $self->filename,
		report => $self->config->report,
		type => $self->type,
		root => $self->root,
	);
}

1;
# ABSTRACT: Generic Report Writer.