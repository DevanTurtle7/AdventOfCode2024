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
    } elsif ($char eq "[" || $char eq "]") {
        my @right_pos = $char eq "]" ? @new_pos : ($x + 1, $y);
        my @left_pos = ($right_pos[0] - 1, $right_pos[1]);

        if ($dir_ref->[1] == 0) {
            my @end_pos = map {$new_pos[$_] + $dir_ref->[$_]} (0..$#new_pos);
            my $can_move = can_move(\@end_pos, $dir_ref);
            return $can_move;
        } else {
            my $move_left = can_move(\@left_pos, $dir_ref);
            my $move_right = can_move(\@right_pos, $dir_ref);
            return $move_left && $move_right;
        }
    } else {
        print("Unknown symbol, $char\n");
        return !!0;
    }
}

sub move {
    my ($pos_ref, $dir_ref) = @_;
    my ($current_x, $current_y) = @{$pos_ref};
    my @new_pos = map {$pos_ref->[$_] + $dir_ref->[$_]} (0..$#$pos_ref);
    my ($x, $y) = @new_pos;
    my $char = $grid{$x}{$y};
    my $current_char = $grid{$current_x}{$current_y};

    if ($char eq "[" || $char eq "]") {
        if ($dir_ref->[1] == 0) {
            move(\@new_pos, $dir_ref);
            $grid{$x}{$y} = $current_char;
            $grid{$current_x}{$current_y} = ".";
        } else {
            my @right_pos = $char eq "]" ? @new_pos : ($x + 1, $y);
            my @left_pos = ($right_pos[0] - 1, $right_pos[1]);
            my ($new_right_x, $new_right_y) = map {$right_pos[$_] + $dir_ref->[$_]} (0..$#right_pos);
            my ($new_left_x, $new_left_y) = map {$left_pos[$_] + $dir_ref->[$_]} (0..$#left_pos);

            my ($right_x, $right_y) = @right_pos;
            my ($left_x, $left_y) = @left_pos;

            move(\@left_pos, $dir_ref);
            move(\@right_pos, $dir_ref);

            $grid{$left_x}{$left_y} = ".";
            $grid{$right_x}{$right_y} = ".";
            $grid{$new_left_x}{$new_left_y} = "[";
            $grid{$new_right_x}{$new_right_y} = "]";
        }
    } else {
        $grid{$x}{$y} = $current_char;
        $grid{$current_x}{$current_y} = ".";
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
                @robot = ($x * 2, $y);
                $char = ".";
            }

            if ($char eq "#" || $char eq ".") {
                $grid{$x * 2}{$y} = $char;
                $grid{($x * 2) + 1}{$y} = $char;
            } elsif ($char eq "O") {
                $grid{$x * 2}{$y} = "[";
                $grid{($x * 2) + 1}{$y} = "]";
            }
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
        my @new_pos = map {$robot[$_] + $move->[$_]} (0..$#robot);
        move(\@robot, $move);
        @robot = @new_pos;
    }
}

my $total = 0;

foreach my $x (keys %grid) {
    foreach my $y (keys %{$grid{$x}}) {
        if ($grid{$x}{$y} eq "[") {
            $total += (100 * $y) + $x;
        }
    }
}


print("$total\n");
