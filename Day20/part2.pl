use strict;
use warnings;

my @start;
my @end;

my %walls;
my %distances;
my %unvisited;
my %visited;

my $min_x = 0;
my $min_y = 0;
my $max_x;
my $max_y;


sub valid_coords {
    my ($x, $y) = @_;

    if ($x < $min_x || $x > $max_x || $y < $min_y || $y > $max_y) {
        return !!0;
    }

    return !!1;
}


sub get_neighbors {
    my ($x, $y) = @_;
    my @neighbors;

    for my $add_x (-1..1) {
        for my $add_y (-1..1) {
            if (abs($add_x) == abs($add_y)) {
                next;
            }

            my $neighbor_x = $x + $add_x;
            my $neighbor_y = $y + $add_y;

            if (!valid_coords($neighbor_x, $neighbor_y) || exists $walls{"$neighbor_x,$neighbor_y"}) {
                next;
            }

            push(@neighbors, [$neighbor_x, $neighbor_y]);
        }
    }

    return @neighbors;
}


open (my $file, "<", "input.txt") or die $!;

my $y = 0;

while (my $line = <$file>) {
    chomp($line);
    $max_x = length($line) - 1;

    for my $x (0..$max_x) {
        my $char = substr($line, $x, 1);
        my $key = "$x,$y";
        
        if ($char eq "S") {
            @start = ($x, $y);
            $distances{$key} = 0;
        } elsif ($char eq "E") {
            @end = ($x, $y);
            $distances{$key} = "inf" + 1;
        } elsif ($char eq "#") {
            $walls{$key} = 1;
        } else {
            $distances{$key} = "inf" + 1;
        }

        unless ($char eq "#") {
            $unvisited{$key} = 1;
        }
    }

    $y++;
}

close ($file);

$max_y = $y - 1;

while (scalar keys %unvisited > 0) {
    my $key;
    my $distance = "inf" + 1;

    foreach my $current_key (keys %unvisited) {
        my $current_distance = $distances{$current_key};

        if ($current_distance < $distance) {
            $distance = $current_distance;
            $key = $current_key;
        }
    }

    delete $unvisited{$key};
    $visited{$key} = 1;
    my ($x, $y) = split(",", $key);
    my @neighbors = get_neighbors($x, $y);
    my $distance_to_neighbor = $distance + 1;

    foreach my $neighbor (@neighbors) {
        my ($x, $y) = @{$neighbor};
        my $neighbor_key = "$x,$y";

        if ($distances{$neighbor_key} > $distance_to_neighbor) {
            $distances{$neighbor_key} = $distance_to_neighbor;
        }
    }
}

my $total = 0;

foreach my $key (keys %distances) {
    my ($x, $y) = split(",", $key);
    my $distance = $distances{$key};

    foreach my $abs_add_x (0..20) {
        foreach my $abs_add_y (0..20-$abs_add_x) {
            if ($abs_add_x == 0 && $abs_add_y == 0) {
                next;
            }

            foreach my $x_sign(0..($abs_add_x == 0 ? 0 : 1)) {
                foreach my $y_sign(0..($abs_add_y == 0 ? 0 : 1)) {
                    my $neighbor_x = $x + $abs_add_x * ($x_sign == 1 ? -1 : 1);
                    my $neighbor_y = $y + $abs_add_y * ($y_sign == 1 ? -1 : 1);
                    my $neighbor_key = "$neighbor_x,$neighbor_y";

                    if (!valid_coords($neighbor_x, $neighbor_y) || exists $walls{$neighbor_key}) {
                        next;
                    }

                    my $neighbor_distance = $distances{$neighbor_key};
                    my $distance_to_neighbor = $abs_add_x + $abs_add_y;
                    my $new_distance = $distance + $distance_to_neighbor;
                    my $distance_saved = $neighbor_distance - $new_distance;

                    if ($distance_saved >= 100) {
                        $total++;
                    }
                }
            }
        }
    }
}

print("$total\n");
