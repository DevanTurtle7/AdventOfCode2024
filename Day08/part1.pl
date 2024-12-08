use strict;
use warnings;
use String::Util qw(trim);

my %nodes;

my $minX = 0;
my $minY = 0;
my $maxX = 0;
my $maxY = 0;

open (my $file, "<", "input.txt") or die $!;

my $y = 0;

while (my $line = <$file>) {
    $line = trim($line);
    $maxX = length($line) - 1;

    for my $x (0..$maxX) {
        my $char = substr($line, $x, 1);
        
        if ($char eq ".") {
            next;
        }

        push(@{$nodes{$char}}, [$x, $y]);
    }

    $y++;
}

close ($file);

$maxY = $y - 1;
my %antinodes;

foreach my $char (keys %nodes) {
    my $nodes_ref = $nodes{$char};
    my @nodes = @$nodes_ref;

    for my $i (0..$#nodes) {
        my $current_coords_ref = $nodes[$i];
        my @current_coords = @$current_coords_ref;

        for my $j ($i+1..$#nodes) {
            my $other_coords_ref = $nodes[$j];
            my @other_coords = @$other_coords_ref;
            my @delta = map {$current_coords[$_] - $other_coords[$_]} 0..$#current_coords;
            
            my @antinode1 = ($current_coords[0] + $delta[0], $current_coords[1] + $delta[1]);
            my @antinode2 = ($other_coords[0] - $delta[0], $other_coords[1] - $delta[1]);
            my @new_antinodes = (\@antinode1, \@antinode2);

            foreach my $k (0..$#new_antinodes) {
                my $antinode_ref = $new_antinodes[$k];
                my @antinode = @$antinode_ref;
                my $x = $antinode[0];
                my $y = $antinode[1];

                if ($x >= $minX && $x <= $maxX && $y >= $minY && $y <= $maxY) {
                    $antinodes{$x}{$y} = 1;
                }
            }
        }
    }
}

my $total = 0;

foreach my $x (keys %antinodes) {
    my $y_ref = $antinodes{$x};
    my %y_hash = %$y_ref;

    foreach my $y (keys %y_hash) {
        $total++;
    }
}

print("$total\n");
