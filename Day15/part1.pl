use strict;
use warnings;

my @robot;
my %grid;
my @moves;

sub can_move {
    my ($pos_ref, $dir_ref) = @_;
    my @new_pos = map {$pos_ref->[$_] + $dir_ref->[$_]} (0..$#$pos_ref);
    my ($x, $y) = @new_pos;
    my $char = $grid{$x}{$y};

    if ($char eq ".") {
        return !!1;
    } elsif ($char eq "#") {
        return !!0;
    } elsif ($char eq "O") {
        my $move_box = can_move(\@new_pos, $dir_ref);

        if ($move_box) {
            $grid{$x}{$y} = ".";
            my ($box_x, $box_y) = map {$new_pos[$_] + $dir_ref->[$_]} (0..$#new_pos);
            $grid{$box_x}{$box_y} = "O";
        }

        return $move_box;
    } else {
        print("Unknown symbol, $char\n");
        return !!0;
    }
}

open (my $file, "<", "input.txt") or die $!;

my $y = 0;
my $mapping = !!1;

while (my $line = <$file>) {
    if ($line eq "\n") {
        $mapping = !!0;
        next;
    }

    chomp ($line);

    if ($mapping) {
        for my $x (0..length($line) - 1) {
            my $char = substr($line, $x, 1);

            if ($char eq "@") {
                @robot = ($x, $y);
                $char = ".";
            }

            $grid{$x}{$y} = $char;
        }

        $y++;
    } else {
        for my $i (0..length($line) - 1) {
            my $char= substr($line, $i, 1);

            if ($char eq "^") {
                push(@moves, [0, -1]);
            } elsif ($char eq "v") {
                push(@moves, [0, 1]);
            } elsif ($char eq "<") {
                push(@moves, [-1, 0]);
            } elsif ($char eq ">") {
                push(@moves, [1, 0]);
            }
        }
    }
}

close ($file);

foreach my $move (@moves) {
    if (can_move(\@robot, $move)) {
        @robot = map {$robot[$_] + $move->[$_]} (0..$#robot);
    }
}

my $total = 0;

foreach my $x (keys %grid) {
    foreach my $y (keys %{$grid{$x}}) {
        if ($grid{$x}{$y} eq 'O') {
            $total += (100 * $y) + $x;
        }
    }
}

print("$total\n");
