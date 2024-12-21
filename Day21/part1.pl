use strict;
use warnings;

my %num_keypad = (
    9 => [2, 0],
    8 => [1, 0],
    7 => [0, 0],
    6 => [2, 1],
    5 => [1, 1],
    4 => [0, 1],
    3 => [2, 2],
    2 => [1, 2],
    1 => [0, 2],
    0 => [1, 3],
    A => [2, 3]
);
my %dir_keypad = (
    "^" => [1, 0],
    A => [2, 0],
    "<" => [0, 1],
    v => [1, 1],
    ">" => [2, 1]
);
my @pointers;
my %valid_num_key_pos;
my %valid_dir_key_pos;

foreach my $key (keys %num_keypad) {
    my ($x, $y) = @{$num_keypad{$key}};
    $valid_num_key_pos{"$x,$y"} = $key;
}

foreach my $key (keys %dir_keypad) {
    my ($x, $y) = @{$dir_keypad{$key}};
    $valid_dir_key_pos{"$x,$y"} = $key;
}

my %dir_keypad_memo;

foreach my $from_key (keys %dir_keypad) {
    foreach my $to_key (keys %dir_keypad) {
        my @permutations;
        @permutations = trace_command($to_key, 0, "", $dir_keypad{$from_key}, \%dir_keypad, \%valid_dir_key_pos, \@permutations);

        foreach my $permutation (@permutations) {
            push(@{$dir_keypad_memo{$from_key}{$to_key}}, $permutation);
        }
    }
}

sub trace_command {
    my ($command, $index, $prev_commands, $position, $keypad_ref, $valid_key_pos_ref, $solutions_ref) = @_;
    my ($x, $y) = @{$position};
    my %keypad = %{$keypad_ref};
    my %valid_key_pos = %{$valid_key_pos_ref};

    if ($index >= length($command)) {
        push(@{$solutions_ref}, $prev_commands);
        return @{$solutions_ref};
    }

    my $to_char = substr($command, $index, 1);
    my $from_char = $valid_key_pos{"$x,$y"};
    my ($button_x, $button_y) = @{$keypad{$to_char}};
    my $delta_x = $button_x - $x;
    my $delta_y = $button_y - $y;

    if (exists $dir_keypad_memo{$from_char} && exists $dir_keypad_memo{$from_char}{$to_char}) {
        my @permutations = @{$dir_keypad_memo{$from_char}{$to_char}};

        foreach my $permutation (@permutations) {
            trace_command($command, $index + 1, $prev_commands.$permutation, [$button_x, $button_y], $keypad_ref, $valid_key_pos_ref, $solutions_ref);
        }
        return @{$solutions_ref};
    }

    if ($delta_x == 0 && $delta_y == 0) {
        return trace_command($command, $index + 1, $prev_commands."A", [$x, $y], $keypad_ref, $valid_key_pos_ref, $solutions_ref);
    }

    if ($delta_x != 0) {
        my $x_dir = $delta_x / abs($delta_x);
        my $new_x = $x + $x_dir;

        if (exists $valid_key_pos{"$new_x,$y"}) {
            my $x_char = $x_dir > 0 ? ">" : "<";
            trace_command($command, $index, $prev_commands.$x_char, [$new_x, $y], $keypad_ref, $valid_key_pos_ref, $solutions_ref);
        }
    }

    if ($delta_y != 0) {
        my $y_dir = $delta_y / abs($delta_y);
        my $new_y = $y + $y_dir;

        if (exists $valid_key_pos{"$x,$new_y"}) {
            my $y_char = $y_dir > 0 ? "v" : "^";
            trace_command($command, $index, $prev_commands.$y_char, [$x, $new_y], $keypad_ref, $valid_key_pos_ref, $solutions_ref);
        }
    }


    return @{$solutions_ref};
}

open (my $file, "<", "input.txt") or die $!;

my $total = 0;

while (my $line = <$file>) {
    chomp($line);
    my $numbers = $line;
    $numbers =~ s/\D//g;
    $numbers += 0;
    my @commands = ($line);
    print("$line\n");

    for my $i (0..2) {
        my $shortest_path = "inf" + 0;
        my @shortest_solutions;

        foreach my $command (@commands) {
            my $keypad = ($i == 0 ? \%num_keypad : \%dir_keypad);
            my @solutions;

            @solutions = trace_command(
                $command, #Command
                0, #Index
                "", # Prev commands
                $keypad->{"A"}, # Position
                $keypad,
                $i == 0 ? \%valid_num_key_pos : \%valid_dir_key_pos,
                \@solutions,
            );

            my %unique;

            foreach my $solution (@solutions) {
                $unique{$solution} = 1;
            }

            foreach my $solution (keys %unique) {
                my $solution_length = length($solution);

                if ($solution_length < $shortest_path) {
                    $shortest_path = $solution_length;
                    @shortest_solutions = ();
                    push(@shortest_solutions, $solution);
                } elsif ($solution_length == $shortest_path) {
                    push(@shortest_solutions, $solution);
                }
            }
        }

        @commands = @shortest_solutions;
    }

    my $command_length = length($commands[0]);
    print("$command_length, $numbers\n");
    $total += $command_length * $numbers;
}

close ($file);
print("$total\n");
