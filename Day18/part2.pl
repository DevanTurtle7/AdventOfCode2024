use strict;
use warnings;

my $min_coord = 0;
my $max_coord = 70;
my %distances;
my %visited;
my %unvisited;
my %bytes;
my %from;

my $corrupted_count = 0;
my $init_corrupted = 1024;
my @corrupted;

my $start_key = "$min_coord,$min_coord";
my $end_key = "$max_coord,$max_coord";

open (my $file, "<", "input.txt") or die $!;

while (my $line = <$file>) {
    chomp ($line);
    push(@corrupted, $line);

    if ($corrupted_count < $init_corrupted) {
        $bytes{$line} = 1;
        $corrupted_count++;
    }
}

close ($file);

sub get_valid_neighbors {
    my ($x, $y) = @_;
    my @neighbors;

    for my $add_x (-1..1) {
        for my $add_y (-1..1) {
            if (abs($add_x) == abs($add_y)) {
                next;
            }

            my $neighbor_x = $x + $add_x;
            my $neighbor_y = $y + $add_y;
            my $neighbor_key = "$neighbor_x,$neighbor_y";

            if (exists $bytes{$neighbor_key} || $neighbor_x > $max_coord || $neighbor_x < $min_coord || $neighbor_y > $max_coord || $neighbor_y < $min_coord) {
                next;
            }

            push(@neighbors, $neighbor_key);
        }
    }

    return @neighbors;
}

for my $y ($min_coord..$max_coord) {
    for my $x ($min_coord..$max_coord) {
        my $key = "$x,$y";
        unless (exists $bytes{$key}) {
            $unvisited{$key} = 1;
            $distances{$key} = "inf" + 0;
        }
    }
}

$distances{$start_key} = 0;
my $unsearchable = !!0;

while (scalar keys %unvisited > 0 && !$unsearchable) {
    my $smallest_key;
    my $smallest_distance = "inf" + 0;

    foreach my $key (keys %unvisited) {
        my $current_distance = $distances{$key};

        if ($current_distance < $smallest_distance) {
            $smallest_key = $key;
            $smallest_distance = $current_distance
        }
    }

    if ($smallest_distance >= "inf" + 0) {
        $unsearchable = !!1;
        next;
    }

    delete $unvisited{$smallest_key};
    $visited{$smallest_key} = 1;
    my ($x, $y) = split(",", $smallest_key);
    my @neighbors = get_valid_neighbors($x, $y);

    foreach my $neighbor_key (@neighbors) {
        my $current_distance = $smallest_distance + 1;
        my $d = $distances{$neighbor_key};

        if ($current_distance <= $distances{$neighbor_key}) {
            $distances{$neighbor_key} = $current_distance;

            if ($current_distance < $distances{$neighbor_key}) {
                $from{$neighbor_key} = [$smallest_key]
            } else {
                if (exists $from{$neighbor_key}) {
                    push(@{$from{$neighbor_key}}, $smallest_key);
                } else {
                    $from{$neighbor_key} = [$smallest_key]
                }
            }
        }
    }
}

sub is_reachable {
    my ($key, $target) = @_;
    my %visited;
    my @queue = ($key);

    while ($#queue >= 0) {
        my $current = pop(@queue);
        my ($x, $y) = split(",", $current);
        my @neighbors = get_valid_neighbors($x, $y);

        foreach my $neighbor_key (@neighbors) {
            if (exists $visited{$neighbor_key}) {
                next;
            }

            $visited{$neighbor_key} = 1;
            push(@queue, $neighbor_key);

            if ($neighbor_key eq $target) {
                return !!1;
            }
        }
    }

    return !!0;
}

my $still_reachable = !!1;
my $new_byte;

while ($still_reachable) {
    $new_byte = $corrupted[$corrupted_count];
    $bytes{$new_byte} = 1;
    $corrupted_count++;

    if (exists $from{$new_byte}) {
        $still_reachable = is_reachable($start_key, $end_key)
    }
}

print("$new_byte\n");
