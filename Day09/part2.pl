use strict;
use warnings;

open (my $file, "<", "input.txt") or die $!;

while (my $line = <$file>) {

}

close ($file);
