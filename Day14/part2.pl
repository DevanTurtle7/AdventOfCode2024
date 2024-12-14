use strict;
use warnings;

open (my $file, "<", "input.txt") or die $!;

my @robots;
my $width = 101;
my $height = 103;
my $num_seconds = 0;
my $mid_x = ($width - 1) / 2;
my $mid_y = ($height - 1) / 2;

while (my $line = <$file>) {
    my @robot = $line =~ /p=(-?\d+),(-?\d+)\s+v=(-?\d+),(-?\d+)/;
    push (@robots, \@robot);
}

close ($file);

my $found = !!0;

while (!$found) {
    my %robot_poses;

    foreach my $robot_ref (@robots) {
        my ($start_x, $start_y, $velocity_x, $velocity_y) = @{$robot_ref};
        my $x = ($start_x + ($velocity_x * $num_seconds)) % $width;
        my $y = ($start_y + ($velocity_y * $num_seconds)) % $height;
        $robot_poses{$x}{$y} = 1;
    }

    foreach my $current_x (keys %robot_poses) {
        foreach my $current_y (keys %{$robot_poses{$current_x}}) {
            if ($found) {
                next;
            }

            my @queue;
            my %visited;

            push(@queue, [$current_x, $current_y]);
            $visited{"$current_x,$current_y"} = 1;

            my $connected_robots = 0;

            while ($#queue >= 0) {
                my ($x, $y) = @{pop(@queue)};
                $connected_robots++;

                for my $add_x (-1..1) {
                    for my $add_y (-1..1) {
                        if ($add_x == 0 && $add_y == 0) {
                            next;
                        }

                        my $neighbor_x = $x + $add_x;
                        my $neighbor_y = $y + $add_y;

                        if (
                            exists $robot_poses{$neighbor_x}{$neighbor_y} &&
                            $robot_poses{$neighbor_x}{$neighbor_y} == 1 &&
                            !(exists $visited{"$neighbor_x,$neighbor_y"})
                        ) {
                            push(@queue, [$neighbor_x, $neighbor_y]);
                            $visited{"$neighbor_x,$neighbor_y"} = 1;
                        }
                    }
                }
            }

            if ($connected_robots > 40) {
                $found = !!1;
            }
        }
    }

    if (!$found) {
        $num_seconds++;
    }
}

print("$num_seconds\n");
