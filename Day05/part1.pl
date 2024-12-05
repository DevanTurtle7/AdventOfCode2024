use strict;
use warnings;
use String::Util 'trim';

open (my $file, "<", "input.txt") or die $!;

my $rules_finished = 0;
my $total = 0;
my %rules;

while (my $line = <$file>) {
    if ($rules_finished eq 0) {
        if ($line eq "\n") {
            $rules_finished = 1;
            next;
        }

        $line =~ /(\d+)\|(\d+)/;

        unless (exists $rules{$1}) {
            $rules{$1} = ();
        }

        push(@{$rules{$1}}, $2);
    } else {
        my @updates = split(",", trim($line));
        my %visited;
        my $rules_broken = 0;

        foreach my $num (@updates) {
            foreach my $prev (@{$rules{$num}}) {
                if (exists $visited{$prev}) {
                    $rules_broken = 1;
                    last;
                }
            }

            if ($rules_broken) {last;}
            $visited{$num} = ();
        }

        unless ($rules_broken) {
            $total += $updates[$#updates / 2];
        }
    }
}

close ($file);

print("Total: $total\n");
