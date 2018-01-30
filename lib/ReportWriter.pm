package ReportWriter;

use 5.010;
use Moose;

use File::ShareDir qw/dist_dir/;

use ReportWriter::Config;
use ReportWriter::Output;

# ABSTRACT: Generic reportwriter

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
	my $config = ReportWriter::Config->with_traits($role)->new(
		config => $self->config_file,
		type => $self->type,
		root => $self->root,
	);
	return $config
}

sub _build_output {
	my $self = shift;
    my $role = 'ReportWriter::Output::Role::' . $self->type;
	my $output = ReportWriter::Output->with_traits($role)->new(
		filename => $self->filename,
		report => $self->config->report,
		type => $self->type,
		root => $self->root,
	);
	return $output;
}

1;
# ABSTRACT: Generic Report Writer.
__END__
=head1 NAME

ReportWriter - Reporting with Perl Moose

=head1 SYNOPSIS

xyzzy

=head1 DESCRIPTION

Yada yada

Things to fear:

=over 4

=item Beasts

=item Witches

=item Ex wifes

=back

Though last two items are more or less the same

=head2 Substitions

=over 4

=item ROW

=item PAGE

=item TOTAL

=item VAR

=back

=head1 METHODS

Methods found in this manual page are shared by the end-user modules,
and should not be used directly: objects of type C<ReportWriter> do not
exist!

=head2 Constructors


=head1 DETAILS

=head1 SEE ALSO

=head1 LICENSE

Copyright 2009 by Kaare Rasmussen.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
See F<http://www.perl.com/perl/misc/Artistic.html>
