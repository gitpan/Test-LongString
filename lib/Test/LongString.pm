package Test::LongString;

use strict;
use vars qw($VERSION @ISA @EXPORT $Max);

$VERSION = 0.03;

use Test::Builder;
my $Tester = new Test::Builder();

use Exporter;
@ISA    = ('Exporter');
@EXPORT = ('is_string','like_string','unlike_string');

# Maximum string length displayed in diagnostics
$Max = 50;

sub import {
    (undef, my %args) = @_;
    $Max = $args{max} if defined $args{max};
    @_ = $_[0];
    goto &Exporter::import;
}

# Formats a string for display.
# This function ought to be configurable, à la od(1).

sub display {
    my $s = shift;
    if (!defined $s) { return 'undef'; }
    if (length($s) > $Max) {
	$s = sprintf(qq("%.${Max}s"...), $s);
    }
    else {
	$s = qq("$s");
    }
    $s =~ s/([\0-\037\200-\377])/sprintf('\x{%02x}',ord $1)/eg;
    return $s;
}

# I'm not too happy with this function. And you ?
sub common_prefix_length {
    my ($x, $y) = (shift, shift);
    my $r = 0;
    while (length($x) && length($y)) {
	my ($x1,$x2) = $x =~ /(.)(.*)/;
	my ($y1,$y2) = $y =~ /(.)(.*)/;
	if ($x1 eq $y1) {
	    $x = $x2;
	    $y = $y2;
	    ++$r;
	}
	else {
	    last;
	}
    }
    $r;
}

sub is_string ($$;$) {
    my ($got, $expected, $name) = @_;
    if (!defined $got || !defined $expected) {
	my $ok = !defined $got && !defined $expected;
	$Tester->ok($ok, $name);
	if (!$ok) {
	    my ($g, $e) = (display($got), display($expected));
	    $Tester->diag(<<DIAG);
         got: $g
    expected: $e
DIAG
	}
	return $ok;
    }
    if ($got eq $expected) {
	$Tester->ok(1, $name);
	return 1;
    }
    else {
	$Tester->ok(0, $name);
	my ($g, $e) = (display($got), display($expected));
	$Tester->diag(<<DIAG);
         got: $g
      length: ${\(length $got)}
    expected: $e
      length: ${\(length $expected)}
    strings begin to differ at char ${\(1+common_prefix_length($got,$expected))}
DIAG
	return 0;
    }
}

sub like_string ($$;$) {
    _like($_[0],$_[1],'=~',$_[2]);
}

sub unlike_string ($$;$) {
    _like($_[0],$_[1],'!~',$_[2]);
}

# mostly from Test::Builder::_regex_ok
sub _like {
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    my ($got, $regex, $cmp, $name) = @_;
    my $ok = 0;
    my $usable_regex = $Tester->maybe_regex($regex);
    unless (defined $usable_regex) {
	$ok = $Tester->ok( 0, $name );
	$Tester->diag("    '$regex' doesn't look much like a regex to me.");
	return $ok;
    }
    {
	local $^W = 0;
	my $test = $got =~ /$usable_regex/ ? 1 : 0;
	$test = !$test if $cmp eq '!~';
	$ok = $Tester->ok( $test, $name );
    }
    unless( $ok ) {
	my $g = display($got);
	my $match = $cmp eq '=~' ? "doesn't match" : "matches";
	my $l = defined $got ? length $got : '-';
	$Tester->diag(sprintf(<<DIAGNOSTIC, $match));
         got: $g
      length: $l
    %13s '$regex'
DIAGNOSTIC
    }
    return $ok;
}

1;

__END__

=head1 NAME

Test::LongString - tests strings for equality

=head1 SYNOPSIS

    use Test::More tests => 1;
    use Test::LongString;
    is_string('foobar','foobur');

=head1 DESCRIPTION

This module provides some drop-in replacements for the string comparison
functions of L<Test::More>, but which are more suitable when you test against
long strings.

The function C<is_string()> basically equivalent to C<Test::More::is()>, but
that gives more verbose diagnostics in case of failure.

=over

=item *

It reports only the 50 first characters of the compared strings in the failure
message, in case of long strings, so this doesn't clutter the test's output.
This threshold value can be changed by setting C<$Test::LongString::Max>, or
by specifying it as an argument to the C<use> directive :

    use Test::LongString max => 100;

=item *

It reports the lengths of the strings that have been compared.

=item *

It reports the length of the common prefix of the strings.

=item *

In the diagnostics, non-ASCII characters are escaped as C<\x{xx}>.

=back

The functions C<like_string()> and C<unlike_string()> are replacements for
C<Test::More:like()> and C<unlike()>, that only print the beginning of the
received string in the output. (I've no way to figure out the position where
the regexp failed to match, if this has a sense.)

=head1 AUTHOR

Written by Rafael Garcia-Suarez. Thanks to Mark Fowler (and to Joss Whedon) for
the inspirational L<Acme::Test::Buffy>.

This program is free software; you may redistribute it and/or modify it under
the same terms as Perl itself.

=head1 SEE ALSO

L<Test::Builder>, L<Test::Builder::Tester>, L<Test::More>.

=cut
