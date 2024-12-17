use strict;
use warnings;

my %nodes;
my @start;
my @end;

my %distances;
my %directions;
my %visited;
my %unvisited;
my %path_tiles;

my $step_cost = 1;
my $rotation_cost = 1000;

sub reaches_end {
    my ($key, $cost, $target, $direction_ref, $visited_ref) = @_;
    my ($x, $y) = split(",", $key);
    my ($end_x, $end_y) = @end;
    my @direction = @{$direction_ref};
    my %visited;

    if ($cost > $target) {
        return !!0;
    }

    foreach my $visited_key (keys %{$visited_ref}) {
        $visited{$visited_key} = $visited_ref->{$visited_key};
    }

    if ($x == $end[0] && $y == $end[1]) {
        print("reached the end\n");
        $path_tiles{"$end_x,$end_y"} = 1;
        return $cost == $target;
    }

    my $result = !!0;

    for my $add_x (-1..1) {
        for my $add_y (-1..1) {
            if (abs($add_x) == abs($add_y)) {
                next;
            }

            my $neighbor_x = $x + $add_x;
            my $neighbor_y = $y + $add_y;
            my $neighbor_key = "$neighbor_x,$neighbor_y";

            if (!exists $nodes{$neighbor_key} || exists $visited{$neighbor_key}) {
                next;
            }

            my $neighbor_cost = $cost + $step_cost;

            unless ($add_x == $direction[0] && $add_y == $direction[1]) {
                if ($add_x == -1 * $direction[0] && $add_y == -1 * $direction[1]) {
                    $neighbor_cost += 2 * $rotation_cost;
                } else {
                    $neighbor_cost += $rotation_cost
                }
            }

            $visited{$key} = 1;

            if (reaches_end($neighbor_key, $neighbor_cost, $target, [$add_x, $add_y], \%visited)) {
                $path_tiles{$key} = 1;
                $result = !!1;
            }
        }
    }

    return $result;
}

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

print("Shortest path done\n");

my ($start_x, $start_y) = @start;
my ($end_x, $end_y) = @end;
my $start_key = "$start_x,$start_y";
my $end_key = "$end_x,$end_y";
my $total_cost = $distances{$end_key};
my %path_visited;

#my ($key, $cost, $target, $direction_ref) = @_;
reaches_end($start_key, 0, $total_cost, [1,0], \%path_visited);

my $num_keys = keys %path_tiles;
print("$num_keys\n");
