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
    my ($start_x, $start_y) = @_;
    my @to_visit = ([$start_x, $start_y]);
    my $plant = $grid{$start_x}{$start_y};
    my %checked;
    my %num_neighbors;

    my $num_plots = 1;
    my $num_fencing = 0;

    $checked{$start_x}{$start_y} = 1;

    while ($#to_visit >= 0) {
        my $coords_ref = pop @to_visit;
        my ($x, $y) = @$coords_ref;
        my $current_fencing = 4;
        $visited{$x}{$y} = 1;

        for my $add_x (-1..1) {
            for my $add_y (-1..1) {
                if (($add_x == 0 && $add_y == 0) || abs($add_x) == abs($add_y)) {
                    next;
                }

                my $neighbor_x = $x + $add_x;
                my $neighbor_y = $y + $add_y;

                if (
                    !valid_coords($neighbor_x, $neighbor_y)
                ) {
                    next;
                }


                if ($grid{$neighbor_x}{$neighbor_y} eq $plant) {
                    $current_fencing--;

                    if (!exists $checked{$neighbor_x}{$neighbor_y}) {
                        push(@to_visit, [$neighbor_x, $neighbor_y]);
                        $checked{$neighbor_x}{$neighbor_y} = 1;
                        $num_plots++;
                    }
                }
            }
        }

        $num_fencing += $current_fencing;
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
        unless (exists $visited{$x} && exists $visited{$x}{$y}) {
            my ($num_plots, $num_fencing) = get_fencing($x, $y);
            $total += $num_plots * $num_fencing;
        }
    }
}

print("$total\n");
