package Test::Translations;

use 5.010;
use Moose;

with 'ReportWriter::Output::Role::Translations';

sub row {
    my ( $self, $row ) = @_;
    return $row;
};

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
=pod

Translations tests

Allowed

$PAGENR
$PAGE{sth}
$VAR{sth]
$TOTAL{sth}
$rowdata
function - or at least some layout, sprintf or sth
$object->method for Datetime, more?
i18n

method       should allow access to

column       (all?) row data, page data, total data

total_column page data, total data

field        page data, total data, page total data

=cut

package main;

use 5.010;
use strict;
use warnings;
use Test::More tests => 10;
use ReportWriter::Field;

my $field = ReportWriter::Field->new(text => 'Page $PAGENR $ROW{number}');

ok(my $test = Test::Translations->new, 'Test instance');
ok($test->column(1,2), 'Column');
ok(my $result = $test->field($field), 'Field');
is($result, 'Page 0 ', 'Page 0');
ok($test->page($field), 'New page');
ok($result = $test->field($field), 'Field');
is($result, 'Page 1 ', 'Page 1');
ok($test->row({number => 12345}), 'Row');
ok($result = $test->field($field), 'Field');
is($result, 'Page 1 12345', 'Page 1');
