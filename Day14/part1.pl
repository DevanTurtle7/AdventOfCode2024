use strict;
use warnings;

open (my $file, "<", "input.txt") or die $!;

my $width = 101;
my $height = 103;
my $num_seconds = 100;
my $mid_x = ($width - 1) / 2;
my $mid_y = ($height - 1) / 2;

my %quadrants;

while (my $line = <$file>) {
    my ($start_x, $start_y, $velocity_x, $velocity_y) = $line =~ /p=(-?\d+),(-?\d+)\s+v=(-?\d+),(-?\d+)/;
    my $end_x = ($start_x + ($velocity_x * $num_seconds)) % $width;
    my $end_y = ($start_y + ($velocity_y * $num_seconds)) % $height;
    my $quadrant_x = $end_x == $mid_x ? -1 : $end_x > $mid_x ? 1 : 0;
    my $quadrant_y = $end_y == $mid_y ? -1 : $end_y > $mid_y ? 1 : 0;

    unless ($quadrant_x == -1 || $quadrant_y == -1) {
        $quadrants{"$quadrant_x,$quadrant_y"}++;
    }
}

close ($file);

my $total = 1;

foreach my $quadrant_key (keys %quadrants) {
    $total *= $quadrants{$quadrant_key};
}

print("$total\n");
