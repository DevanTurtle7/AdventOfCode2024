use strict;
use warnings;
use String::Util qw(trim);

my %obstacles;
my @orig_start_position;
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
            @orig_start_position = ($x, $y);
        }
    }

    $y++;
}

close ($file);

$maxY = $y - 1;

sub run_simulation {
    my ($start_position_ref, $extra_obstacle_ref, $direction_ref) = @_;
    my @start_position = @$start_position_ref;
    my @extra_obstacle = @$extra_obstacle_ref;
    my @direction = @$direction_ref;
    my %positions;
    my %prev_positions;


    if (exists $obstacles{$extra_obstacle[0]}{$extra_obstacle[1]}) {
        return wantarray() ? (1, \%positions, \%prev_positions) : 1;
    }

    my $current_x = $start_position[0];
    my $current_y = $start_position[1];
    my $moved = 1; # Set to 1 so that starting position is saved first iteration

    my $start_position_key = "$current_x,$current_y";
    my @positions = ($current_x, $current_y);
    my @direction_copy = ($direction[0], $direction[1]);
    my @data = (\@positions, \@direction_copy);
    
    $prev_positions{$start_position_key} = \@data;

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
                return wantarray() ? (0, \%positions, \%prev_positions) : 0;
            }
        }

        my $new_x = $current_x + $direction[0];
        my $new_y = $current_y + $direction[1];

        if (exists $obstacles{$new_x}{$new_y} || ($new_x eq $extra_obstacle[0] && $new_y eq $extra_obstacle[1])) {
            # Rotate 90
            @direction = ($direction[1] * -1, $direction[0]);
            $moved = 0;
        } else {
            if (wantarray()) {
                my $key = "$new_x,$new_y";

                unless (exists $prev_positions{$key}) {
                    my @positions = ($current_x, $current_y);
                    my @direction_copy = ($direction[0], $direction[1]);
                    my @data = (\@positions, \@direction_copy);
                    
                    $prev_positions{$key} = \@data;
                }
            }

            # Move forward
            $current_x = $new_x;
            $current_y = $new_y;
            $moved = 1;
        }
    }

    return wantarray() ? (1, \%positions, \%prev_positions) : 1;
}

my $total = 0;
my @dummy_obstacle = ($minX - 1, $minY - 1);
my @direction = (0, -1);
my ($result, $trail_ref, $prev_positions_ref) = run_simulation(\@orig_start_position, \@dummy_obstacle, \@direction);
my %trail = %$trail_ref;
my %prev_positions = %$prev_positions_ref;

foreach my $position_key (keys %trail) {
    my @coords = split(",", $position_key);

    my $prev_position_data_ref = $prev_positions{$position_key};
    my $start_position_ref = @$prev_position_data_ref[0];
    my $direction_ref = @$prev_position_data_ref[1];
    my @start_position = @$start_position_ref;
    my @direction = @$direction_ref;

    my $result = run_simulation(\@start_position, \@coords, \@direction);

    unless ($result) {
        $total += 1;
    }
}

print("$total\n");
