#!perl -w

use strict;

use Test::More tests => 7;
use Test::Builder::Tester;
use Test::Builder::Tester::Color;

BEGIN { use_ok "Test::LongString" }

test_out("ok 1 - foo is foo");
is_string("foo", "foo", "foo is foo");
test_test("two small strings equal");

test_out("not ok 1 - foo is foo");
test_fail(6);
test_diag(qq(         got: "bar"
#       length: 3
#     expected: "foo"
#       length: 3
#     strings begin to differ at char 1));
is_string("bar", "foo", "foo is foo");
test_test("two small strings different");

test_out("not ok 1 - foo is foo");
test_fail(3);
test_diag(qq(         got: undef
#     expected: "foo"));
is_string(undef, "foo", "foo is foo");
test_test("got undef, expected small string");

test_out("not ok 1 - foo is foo");
test_fail(3);
test_diag(qq(         got: "foo"
#     expected: undef));
is_string("foo", undef, "foo is foo");
test_test("expected undef, got small string");

test_out("not ok 1 - long binary strings");
test_fail(6);
test_diag(qq(         got: "This is a long string that will be truncated by th"...
#       length: 70
#     expected: "\\x{00}\\x{01}foo\\x{0a}bar"
#       length: 9
#     strings begin to differ at char 1));
is_string(
    "This is a long string that will be truncated by the display() function",
    "\0\1foo\nbar",
    "long binary strings",
);
test_test("display of long strings and of control chars");

test_out("not ok 1 - spelling");
test_fail(6);
test_diag(qq(         got: "Element"
#       length: 7
#     expected: "El\\x{e9}ment"
#       length: 7
#     strings begin to differ at char 3));
is_string(
    "Element",
    "Elément",
    "spelling",
);
test_test("Escape high-ascii chars");
