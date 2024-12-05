
use strict; use warnings;
use String::Util 'trim';

my $target_str = "XMAS";
my $grid = {};
my @a_coords;

my $y = 0;

open(my $file, "<", "input.txt") or die $!;

while (my $line = <$file>) {
    my $line = trim($line);

    for my $x (0..length($line)) {
        if (!exists $grid->{$x}) {
            $grid->{$x} = {};
        }

        my $char = substr($line, $x, 1);
        $grid->{$x}->{$y} = $char;

        if ($char eq "A") {
            my @coords = ($x, $y);
            push (@a_coords, \@coords);
        }
    }

    $y++;
}

close ($file);

my $total = 0;

foreach my $coords (@a_coords) {
    my $a_x = $coords->[0];
    my $a_y = $coords->[1];

    my @neighbor_coords = map {my $x = $_; my @array = map{my @array = ($x, $_); \@array} (-1, 1); @array} (-1, 1);

    my @valid_coords = map {
        my $x = $a_x + $_->[0];
        my $y = $a_y + $_->[1];
        my @current_coords = ($x, $y);

        exists $grid->{$x} && exists $grid->{$x}->{$y} ? \@current_coords : ();
    } @neighbor_coords;

    my %char_counts;

    foreach my $valid_coord (@valid_coords) {
        my $valid_x = $valid_coord->[0];
        my $valid_y = $valid_coord->[1];
        my $char = $grid->{$valid_x}->{$valid_y};

        $char_counts{$char}++;
    }
    
    if (
        exists $char_counts{"M"} &&
        exists $char_counts{"S"} &&
        $char_counts{"M"} eq 2 && 
        $char_counts{"S"} eq 2 && 
        $grid->{$a_x + 1}->{$a_y+1} ne $grid->{$a_x - 1}->{$a_y - 1}
    ) {
        $total++;
    }
}


print("Total: $total\n")
