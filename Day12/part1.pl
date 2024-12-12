use strict;
use warnings;

my %grid;
my %visited;

my $minY = 0;
my $minX = 0;
my $maxX;
my $maxY;

my $y = 0;

sub valid_coords {
    my ($x, $y) = @_;

    return $x >= $minX && $x <= $maxX && $y >= $minY &&  $y <= $maxY;
}


sub get_fencing {
    my ($x, $y) = @_;
    my @neighbors;

    for my $add_x (-1..1) {
        for my $add_y (-1..1) {
            if (($add_x == 0 && $add_y == 0) || abs($add_x) == abs($add_y)) {
                next;
            }

            my $neighbor_x = $x + $add_x;
            my $neighbor_y = $y + $add_y;

            if (!valid_coords($neighbor_x, $neighbor_y)) {
                next;
            }

            if ($grid{$neighbor_x}{$neighbor_y} eq $grid{$x}{$y}) {
                push(@neighbors, [$neighbor_x, $neighbor_y]);
            }
        }
    }

    my $num_plots = 1;
    my $num_fencing = 4 - ($#neighbors + 1);
    my $key = "$x,$y";

    $visited{$key} = 1;

    foreach my $neighbor_coords_ref (@neighbors) {
        my @neighbor_coords = @$neighbor_coords_ref;
        my ($neighbor_x, $neighbor_y) = @neighbor_coords;
        my $neighbor_key = "$neighbor_x,$neighbor_y";
        
        if (exists $visited{$neighbor_key}) {
            next;
        }

        my ($num_neighbor_plots, $num_neighbor_fencing) = get_fencing($neighbor_x, $neighbor_y);
        $num_plots += $num_neighbor_plots;
        $num_fencing += $num_neighbor_fencing;
    }

    return ($num_plots, $num_fencing);
}

open (my $file, "<", "input.txt") or die $!;

while (my $line = <$file>) {
    chomp ($line);
    $maxX = length($line) - 1;

    for my $x (0..$maxX) {
        my $char = substr($line, $x, 1);
        $grid{$x}{$y} = $char;
    }

    $y++;
}

close ($file);

$maxY = $y - 1;

my $total = 0;

foreach my $x (keys %grid) {
    my $y_hash_ref = $grid{$x};
    my %y_hash = %$y_hash_ref;

    foreach my $y (keys %y_hash) {
        my $key = "$x,$y";
        unless (exists $visited{$key}) {
            my ($num_plots, $num_fencing) = get_fencing($x, $y);
            $total += $num_plots * $num_fencing;
        }
    }
}

print("$total\n");
