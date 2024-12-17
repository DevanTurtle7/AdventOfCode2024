use strict;
use warnings;

my %nodes;
my @start;
my @end;

my %distances;
my %visited;
my %unvisited;
my %from;

my $step_cost = 1;
my $rotation_cost = 1000;

my @north = (0, -1);
my @east = (1, 0);
my @south = (0, 1);
my @west = (-1, 0);
my @directions = (\@north, \@east, \@south, \@west);

sub rotations_to_match {
    my ($start_direction_ref, $end_direction_ref) = @_;
    my @start_direction = @{$start_direction_ref};
    my @end_direction = @{$end_direction_ref};
    my ($start_x, $start_y) = @start_direction;
    my ($end_x, $end_y) = @end_direction;

    if ($start_x == $end_x && $start_y == $end_y) {
        return 0;
    } elsif ($start_x == -1 * $end_x && $start_y == -1 * $end_y) {
        return 2;
    } else {
        return 1;
    }
}

sub back_traverse {
    my ($key) = @_;
    my @queue = ($key);
    my %visited_nodes;
    my %visited_keys;

    my ($init_x, $init_y, $init_dir_x, $init_dir_y) = split(",", $key);
    $visited_nodes{"$init_x,$init_y"} = 1;
    $visited_keys{$key} = 1;

    while ($#queue >= 0) {
        my $current_key = pop(@queue);
        my ($x, $y, $dir_x, $dir_y) = split(",", $current_key);

        if ($x == $start[0] && $y == $start[1]) {
            next;
        }

        foreach my $connected (@{$from{$current_key}}) {
            my ($conn_x, $conn_y, $conn_dir_x, $conn_dir_y) = split(",", $connected);

            unless (exists $visited_keys{$connected}) {
                my $distance = $distances{$connected};
                $visited_nodes{"$conn_x,$conn_y"} = 1;
                $visited_keys{$connected} = 1;
                push(@queue, $connected);
            }
        }
    }

    return scalar keys %visited_nodes;
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

            if ($char eq "S") {
                @start = ($x, $y);
            } elsif ($char eq "E") {
                @end = ($x, $y);
            }
        }
    }

    $y++;
}

close ($file);

foreach my $key (keys %nodes) {
    my ($x, $y) = split(",", $key);

    if ($x == $start[0] && $y == $start[1]) {
        my $key = "$x,$y,1,0";
        $distances{$key} = 0;
        $unvisited{$key} = 1;
        next;
    } elsif ($x == $end[0] && $y == $end[1]) {
        foreach my $direction (@directions) {
            my ($dir_x, $dir_y) = @{$direction};
            $distances{"$x,$y,$dir_x,$dir_y"} = "inf" + 0;
            $unvisited{"$x,$y,$dir_x,$dir_y"} = 1
        }
    }

    foreach my $direction (@directions) {
        my ($dir_x, $dir_y) = @{$direction};
        my $neighbor_x = $x + $dir_x;
        my $neighbor_y = $y + $dir_y;

        if (exists $nodes{"$neighbor_x,$neighbor_y"}) {
            $distances{"$x,$y,$dir_x,$dir_y"} = "inf" + 0;
            $unvisited{"$x,$y,$dir_x,$dir_y"} = 1
        }
    }
}

while (scalar keys %unvisited > 0) {
    my $num_unvisited = scalar keys %unvisited;
    print("$num_unvisited\n");

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

    my ($x, $y, $dir_x, $dir_y) = split(",", $current_key);

    foreach my $direction (@directions) {
        my ($add_x, $add_y) = @{$direction};
        my $neighbor_x = $x + $add_x;
        my $neighbor_y = $y + $add_y;
        my $neighbor_key = "$neighbor_x,$neighbor_y";

        unless (exists $nodes{$neighbor_key}) {
            next;
        }

        my $cost_to_enter = $distances{$current_key} + $step_cost + ($rotation_cost * rotations_to_match([$dir_x, $dir_y], [$add_x, $add_y]));

        for my $neighbor_direction (@directions) {
            my ($neighbor_dir_x, $neighbor_dir_y) = @{$neighbor_direction};
            my $direction_key = "$neighbor_key,$neighbor_dir_x,$neighbor_dir_y";

            if (exists $distances{$direction_key}) {
                my $cost_to_match = $cost_to_enter + ($rotation_cost * rotations_to_match([$add_x, $add_y], [$neighbor_dir_x, $neighbor_dir_y]));

                if ($cost_to_match < $distances{$direction_key}) {
                    $distances{$direction_key} = $cost_to_match;
                    $from{$direction_key} = [$current_key];
                } elsif ($cost_to_match == $distances{$direction_key}) {
                    if (exists $from{$direction_key}) {
                        push(@{$from{$direction_key}}, $current_key);
                    } else {
                        $from{$direction_key} = [$current_key];
                    }
                }
            }
        }
    }
}

print("Shortest path done\n");

my ($end_x, $end_y) = @end;
my $end_key;
my $total_cost = "inf" + 0;

for my $dir_x (-1..1) {
    for my $dir_y (-1..1) {
        if (abs($dir_x) == abs($dir_y)) {
            next;
        }
        my $current_end_key = "$end_x,$end_y,$dir_x,$dir_y";

        if (exists $distances{$current_end_key}) {
            if ($distances{$current_end_key} < $total_cost) {
                $total_cost = $distances{$current_end_key};
                $end_key = $current_end_key;
            }
        }
    }
}

my $num_tiles = back_traverse($end_key);
print("$total_cost, $num_tiles\n");
