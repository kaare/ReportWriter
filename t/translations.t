package Test::Translations;

use 5.010;
use Moose;

with 'ReportWriter::Output::Role::Translations';

sub column {
    my ( $self, $value, $column ) = @_;
};

sub total_column {
};

sub field {
    my ($self, $field) = @_;
    $field->result;
};

sub page {
    return 1;
};

1;

package main;

use 5.010;
use strict;
use warnings;
use Test::More tests => 7;
use ReportWriter::Field;

my $field = ReportWriter::Field->new(text => 'Page $PAGENR');

ok(my $test = Test::Translations->new, 'Test instance');
ok($test->column(1,2), 'Column');
ok(my $result = $test->field($field), 'Field');
is($result, 'Page 0', 'Page 0');
ok($test->page($field), 'New page');
ok($result = $test->field($field), 'Field');
is($result, 'Page 1', 'Page 1');