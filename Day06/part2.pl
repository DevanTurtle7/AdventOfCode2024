use strict;
use warnings;
use String::Util qw(trim);

my %obstacles;
my @start_position;
my $y = 0;

my $minX = 0;
my $minY = 0;
my $maxX;
my $maxY;

open (my $file, "<", "input.txt") or die $!;

while (my $line = <$file>) {
    $line = trim($line);
    $maxX = length($line) - 1;

    foreach my $x (0..$maxX) {
        my $char = substr($line, $x, 1);

        if ($char eq "#") {
            $obstacles{$x}{$y} = 1;
        } elsif ($char eq "^") {
            @start_position = ($x, $y);
        }
    }

    $y++;
}

close ($file);

$maxY = $y - 1;

sub run_simulation {
    my ($start_position_ref, $extra_obstacle_ref) = @_;
    my @start_position = @$start_position_ref;
    my @extra_obstacle = @$extra_obstacle_ref;
    my %positions;

    if (exists $obstacles{$extra_obstacle[0]}{$extra_obstacle[1]}) {
        return (1, \%positions);
    }

    my $current_x = $start_position[0];
    my $current_y = $start_position[1];
    my @direction = (0, -1);
    my $moved = 1; # Set to 1 so that starting position is saved first iteration

    while ($current_x >= $minX && $current_x <= $maxX && $current_y >= $minY && $current_y <= $maxY) {
        if ($moved) {
            my $key = "$current_x,$current_y";
            my $key_exists = exists $positions{$key};
            my $match_found = 0;

            if ($key_exists) {
                my @prev_directions = @{$positions{$key}};

                foreach my $prev_direction (@prev_directions) {
                    my $prev_x = $prev_direction->[0];
                    my $prev_y = $prev_direction->[1];

                    if ($prev_direction->[0] == $direction[0] && $prev_direction->[1] == $direction[1]) {
                        $match_found = 1;
                        last;
                    }
                }
            }

            if (!$match_found || !$key_exists) {
                my @current_direction = ($direction[0], $direction[1]);
                push(@{$positions{$key}}, \@current_direction);
            } elsif ($match_found) {
                # Looping
                return (0, \%positions);
            }
        }

        my $new_x = $current_x + $direction[0];
        my $new_y = $current_y + $direction[1];

        if (exists $obstacles{$new_x}{$new_y} || ($new_x eq $extra_obstacle[0] && $new_y eq $extra_obstacle[1])) {
            # Rotate 90
            @direction = ($direction[1] * -1, $direction[0]);
            $moved = 0;
        } else {
            # Move forward
            $current_x = $new_x;
            $current_y = $new_y;
            $moved = 1;
        }
    }

    return (1, \%positions);
}

my $total = 0;
my @dummy_obstacle = ($minX - 1, $minY - 1);
my ($result, $trail_ref) = run_simulation(\@start_position, \@dummy_obstacle);
my %trail = %$trail_ref;

foreach my $position_key (keys %trail) {
    my @coords = split(",", $position_key);
    my ($result) = run_simulation(\@start_position, \@coords);

    unless ($result) {
        $total += 1;
        print("$total\n");
    }
}

print("$total\n");
