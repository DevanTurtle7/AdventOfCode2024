use strict;
use warnings;

my %connections;
my %visited;

sub find_groups {
    my ($computer) = @_;
    my %pairs;
    my $num_pairs = 0;

    foreach my $neighbor1 (keys %{$connections{$computer}}) {
        foreach my $neighbor2 (keys %{$connections{$computer}}) {
            if ($neighbor1 eq $neighbor2 || exists $visited{$neighbor1} || exists $visited {$neighbor2}) {
                next;
            }

            if (exists $pairs{$neighbor1} && exists $pairs{$neighbor1}{$neighbor2}) {
                next;
            }

            if (exists $connections{$neighbor1}{$neighbor2}) {
                my @all_computers = ($computer, $neighbor1, $neighbor2);
                my $starts_with_t = grep {substr($_, 0, 1) eq "t"} @all_computers;

                if ($starts_with_t) {
                    $pairs{$neighbor1}{$neighbor2} = 1;
                    $pairs{$neighbor2}{$neighbor1} = 1;
                    $num_pairs++;
                }
            }
        }
    }

    return $num_pairs;
}

open (my $file, "<", "input.txt") or die $!;

while (my $line = <$file>) {
    chomp($line);

    my ($computer1, $computer2) = split("-", $line);
    $connections{$computer1}{$computer2} = 1;
    $connections{$computer2}{$computer1} = 1;
}

close ($file);

my $total = 0;

foreach my $computer (keys %connections) {
    $visited{$computer} = 1;
    $total += find_groups($computer);
}

print("$total\n");
