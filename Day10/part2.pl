use strict;
use warnings;
use String::Util qw(trim);
use List::Util qw(max);

my %grid;
my %scores;
my @trailheads;
my @peaks;

my $minY = 0;
my $minX = 0;
my $maxX;
my $maxY;

sub valid_coords {
    my ($x, $y) = @_;

    return $x >= $minX && $x <= $maxX && $y >= $minY &&  $y <= $maxY;
}

sub calculate_scores {
    my ($x, $y, $key) = @_;
    my $height = $grid{$x}{$y};

    for my $add_x (-1..1) {
        for my $add_y (-1..1) {
            my $neighbor_x = $x + $add_x;
            my $neighbor_y = $y + $add_y;

            if (abs($add_x) eq abs($add_y) || !valid_coords($neighbor_x, $neighbor_y)) {
                next;
            }

            my $neighbor_height = $grid{$neighbor_x}{$neighbor_y};

            if ($neighbor_height eq $height - 1) {
                $scores{$neighbor_x}{$neighbor_y} += 1;
                calculate_scores($neighbor_x, $neighbor_y, $key);
            }
        }
    }
}

open (my $file, "<", "input.txt") or die $!;

my $y = 0;

while (my $line = <$file>) {
    $line = trim($line);
    $maxX = length($line) - 1;
    
    for my $x (0..$maxX) {
        my $height = substr($line, $x, 1);
        $grid{$x}{$y} = $height;
        
        if ($height eq 9) {
            push(@peaks, [$x, $y]);
        } elsif ($height eq 0) {
            push(@trailheads, [$x, $y]);
        }
    }

    $y++;
}

close ($file);

$maxY = $y - 1;

foreach my $coords_ref (@peaks) {
    my @coords = @$coords_ref;
    my ($x, $y) = @coords;
    my $key = "$x,$y";

    calculate_scores($x, $y, $key);
}

my $total = 0;

foreach my $coords_ref (@trailheads) {
    my @coords = @$coords_ref;
    my ($x, $y) = @coords;
    
    my $score = $scores{$x}{$y};
    $total += $score;
}

print("$total\n");
