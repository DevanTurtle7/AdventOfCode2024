use strict;
use warnings;

my $min_coord = 0;
my $max_coord = 70;
my %distances;
my %visited;
my %unvisited;
my %bytes;

my $corrupted_count = 0;
my $corrupted = 1024;

open (my $file, "<", "input.txt") or die $!;

while (my $line = <$file>) {
    if ($corrupted_count < $corrupted) {
        chomp ($line);
        my ($x, $y) = split(",", $line);
        $bytes{$line} = 1;
        $corrupted_count++;
    }
}

close ($file);

for my $y ($min_coord..$max_coord) {
    for my $x ($min_coord..$max_coord) {
        my $key = "$x,$y";
        unless (exists $bytes{$key}) {
            $unvisited{$key} = 1;
            $distances{$key} = "inf" + 0;
        }
    }
}

$distances{"$min_coord,$min_coord"} = 0;
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

            my $current_distance = $smallest_distance + 1;
            my $d = $distances{$neighbor_key};

            if ($current_distance < $distances{$neighbor_key}) {
                $distances{$neighbor_key} = $current_distance;
            }
        }
    }
}

my $distance = $distances{"$max_coord,$max_coord"};
print("$distance\n");
