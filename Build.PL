# Build.PL for ReportWriter

use strict;
use warnings;
use Module::Build;

my $build = Module::Build->new(
    dist_author          => 'Kaare Rasmussen, <kaare@jasonic.dk>',
    dist_abstract        => 'Generic Perl Moose ReportWriter',
    module_name          => 'ReportWriter',
    dist_version_from    => 'lib/ReportWriter.pm',
    license              => 'restrictive',
    recursive_test_files => 1,
    requires             => {
        'File::ShareDir'      => '1.00',
        'Hash::Merge'         => '0.10',
        'Moose'               => '0.64',
        'Paper::Specs'        => '0.10',
        'String::Interpolate' => '0.30',
        'YAML::Tiny'          => '1.32',
    },
    recommends => {
        'OpenOffice::OOCBuilder' => '0',
        'PDF::API2'              => '0',
    },
);
$build->create_build_script();

1;
