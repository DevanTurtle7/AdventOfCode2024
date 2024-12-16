use strict;
use warnings;

my %nodes;
my @start;
my @end;

my %distances;
my %directions;
my %visited;
my %unvisited;

open (my $file, "<", "input.txt") or die $!;

my $y = 0;

while (my $line = <$file>) {
    chomp($line);

    for my $x (0..length($line) - 1) {
        my $char = substr($line, $x, 1);

        if ($char eq "." || $char eq "E" || $char eq "S") {
            my $key = "$x,$y";
            $nodes{$key} = 1;
            $distances{$key} = "inf" + 0;
            $unvisited{$key} = 1;

            if ($char eq "S") {
                @start = ($x, $y);
                $distances{$key} = 0;
                $directions{$key} = [1, 0];
            } elsif ($char eq "E") {
                @end = ($x, $y);
            }
        }
    }

    $y++;
}

close ($file);

my $step_cost = 1;
my $rotation_cost = 1000;

while (scalar keys %unvisited > 0) {
    my $current_key;
    my $distance = "inf" + 0;

    foreach my $key (keys %unvisited) {
        my $current_distance = $distances{$key};

        if ($current_distance < $distance) {
            $distance = $current_distance;
            $current_key = $key;
        }
    }

    $visited{$current_key} = 1;
    delete $unvisited{$current_key};

    my ($x, $y) = split(",", $current_key);
    my @direction = @{$directions{$current_key}};
    my ($dir_x, $dir_y) = @direction;

    for my $add_x (-1..1) {
        for my $add_y (-1..1) {
            if (abs($add_x) == abs($add_y)) {
                next;
            }

            my $neighbor_x = $x + $add_x;
            my $neighbor_y = $y + $add_y;
            my $neighbor_key = "$neighbor_x,$neighbor_y";

            unless (exists $nodes{$neighbor_key}) {
                next;
            }

            my $cost = $distance + $step_cost;

            unless ($add_x == $direction[0] && $add_y == $direction[1]) {
                if ($add_x == -1 * $direction[0] && $add_y == -1 * $direction[1]) {
                    $cost += 2 * $rotation_cost;
                } else {
                    $cost += $rotation_cost
                }
            }

            if ($cost < $distances{$neighbor_key}) {
                $distances{$neighbor_key} = $cost;
                $directions{$neighbor_key} = [$add_x, $add_y];
            }
        }
    }
}

my ($end_x, $end_y) = @end;
my $end_key = "$end_x,$end_y";
my $total_cost = $distances{$end_key};

print("$total_cost\n");
