use ExtUtils::MakeMaker;

# Skip Subversion hidden directories
sub MY::libscan {
    my $path = $_[1];
    return '' if $path =~ /\B\.svn\b/;
    return $path;
}

WriteMakefile(
    NAME	    => "Test::LongString",
    VERSION_FROM    => "lib/Test/LongString.pm",
    PREREQ_PM	    => {
	'Test::Builder'		=> 0.12,
	'Test::Builder::Tester'	=> 0.09,
    },
    dist	    => {
	PREOP	    => 'svn log -r HEAD:1 > ${DISTVNAME}/Changes',
	CI	    => 'svn commit',
	RCS_LABEL   => '@ :',
    },
);
