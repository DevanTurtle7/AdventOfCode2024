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

my $current_x = $start_position[0];
my $current_y = $start_position[1];
my @direction = (0, -1);
my %positions;

while ($current_x >= $minX && $current_x <= $maxX && $current_y >= $minY && $current_y <= $maxY) {
    $positions{"$current_x,$current_y"} = 1;

    if (exists $obstacles{$current_x + $direction[0]}{$current_y + $direction[1]}) {
        # Rotate 90
        @direction = ($direction[1] * -1, $direction[0]);
    } else {
        # Move forward
        $current_x += $direction[0];
        $current_y += $direction[1];
    }
}

my $num_positions = keys %positions;
print("$num_positions\n");
