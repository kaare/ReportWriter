package ReportWriter::Types;

use 5.010;
use Moose;
use Moose::Util::TypeConstraints;

enum 'alignment'   => [ qw(left center right) ];
enum 'boxtype'     => [ qw(normal rounded) ] ;
enum 'direction'   => [ qw(horizontal vertical) ];
enum 'orientation' => [ qw(portrait landscape) ];
enum 'report_type' => [ qw(Array Text PDF) ];
enum 'unit'        => [ qw(pt mm) ];

no Moose::Util::TypeConstraints;

no Moose;

1;
