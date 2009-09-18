#!/usr/bin/env perl
# use strict;
# use warnings;

# Run this script periodically to remove old duplicate commands from your
# bash history file ($HISTFILE).

my $histfile = $ENV{HISTFILE} || $ARGV[0] or die
'$HISTFILE not found: check that "export HISTFILE" is in your .bashrc'."\n";

open HISTFILE, '+<', $histfile or die "$histfile: $!\n";

my %seen = ();
my @unique = reverse grep { not $seen{ $_ }++ } reverse <HISTFILE>;

truncate HISTFILE, 0;
seek HISTFILE, 0, 0;
print HISTFILE @unique;
