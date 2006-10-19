#!perl -w

use strict;

use Test::More tests => 1;
use Test::Builder::Tester;
use Test::Builder::Tester::Color;
use Test::LongString max => 5;

test_out("not ok 1 - foobar is foobar");
test_fail(6);
test_diag(qq(         got: "foobu"...
#       length: 6
#     expected: "fooba"...
#       length: 6
#     strings begin to differ at char 5));
is_string("foobur", "foobar", "foobar is foobar");
test_test("5 chars in output");