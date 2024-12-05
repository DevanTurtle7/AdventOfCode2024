use strict;
use warnings;
use String::Util 'trim';

my $target_str = "XMAS";
my $grid = {};
my @x_coords;

my $y = 0;

sub trace_string {
    my $x = shift;
    my $y = shift;
    my $index = shift;
    my $x_dir = shift;
    my $y_dir = shift;

    unless (exists $grid->{$x}) {return 0;}
    unless (exists $grid->{$x}->{$y}) {return 0;}

    my $a = substr($target_str, $index, 1);
    my $b = $grid->{$x}->{$y};
    my $c = $a eq $b;

    if (substr($target_str, $index, 1) eq $grid->{$x}->{$y}) {
        if ($index == length($target_str) - 1) {
            return 1;
        } else {
            return trace_string($x + $x_dir, $y + $y_dir, $index + 1, $x_dir, $y_dir);
        }
    } else {
        return 0;
    }
}

open(my $file, "<", "input.txt") or die $!;

while (my $line = <$file>) {
    my $line = trim($line);

    for my $x (0..length($line)) {
        if (!exists $grid->{$x}) {
            $grid->{$x} = {};
        }

        my $char = substr($line, $x, 1);
        $grid->{$x}->{$y} = $char;

        if ($char eq "X") {
            my @coords = ($x, $y);
            push (@x_coords, \@coords);
        }
    }

    $y++;
}

close ($file);

my $total = 0;

foreach my $coords (@x_coords) {
    foreach my $x_dir (-1..1) {
        foreach my $y_dir (-1..1) {
            unless ($x_dir eq 0 && $y_dir eq 0) {
                $total += trace_string($coords->[0], $coords->[1], 0, $x_dir, $y_dir);
            }
        }
    }
}

print("Total: $total\n")
