use strict;
use warnings;
use String::Util 'trim';
use List::Util 'min';

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
        my $reordered = 0;

        foreach my $i (0..$#updates) {
            my $num = $updates[$i];
            my @conflict_indexes = map {exists $visited{$_} ? $visited{$_} : ()} @{$rules{$num}};

            if ($#conflict_indexes >= 0) {
                my $first_conflict = min(@conflict_indexes);

                splice(@updates, $i, 1);
                splice(@updates, $first_conflict, 0, $num);

                $visited{$num} = $first_conflict;

                foreach my $j (0..$i) {
                    my $current = $updates[$j];

                    if (exists $visited{$current}) {
                        $visited{$current} = $j;
                    }
                }

                $reordered = 1;
            } else {
                $visited{$num} = $i;
            }
        }

        if ($reordered) {
            $total += $updates[$#updates / 2];
        }
    }
}

close ($file);

print("Total: $total\n");
