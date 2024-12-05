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
        my $reordered = 0;

        foreach my $i (0..$#updates) {
            my $num = $updates[$i];
            my $conflict = 0;
            my $conflict_index = 0;

            foreach my $prev (@{$rules{$num}}) {
                if (exists $visited{$prev}) {
                    my $current_conflict_index = $visited{$prev};

                    if (!$conflict || ($conflict && $conflict_index > $current_conflict_index)) {
                        $conflict_index = $current_conflict_index;
                    }

                    $conflict = 1;
                    $reordered = 1;
                }
            }

            if ($conflict) {
                splice(@updates, $i, 1);
                splice(@updates, $conflict_index, 0, $num);

                $visited{$num} = $conflict_index;

                foreach my $j (0..$i) {
                    my $current = $updates[$j];

                    if (exists $visited{$current}) {
                        $visited{$current} = $j;
                    }
                }
            } else {
                $visited{$num} = $i;
            }
        }

        if ($reordered) {
            $total += $updates[$#updates / 2];
        }
    }
}

print("Total: $total\n");
