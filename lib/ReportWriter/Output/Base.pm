package ReportWriter::Output::Base;

use 5.010;
use Moose::Role;

requires qw(row report);

no Moose;

1;
