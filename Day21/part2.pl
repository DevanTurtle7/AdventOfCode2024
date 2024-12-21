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

my %move_memo;

sub memoized_move {
    my ($from_key, $to_key, $keypad_ref, $valid_key_pos_ref) = @_;
    my %keypad = %{$keypad_ref};
    my %valid_key_pos = %{$valid_key_pos_ref};

    if (exists $move_memo{$from_key} && exists $move_memo{$from_key}{$to_key}) {
        return $move_memo{$from_key}{$to_key};
    }

    my $command_str = "";
    my ($x, $y) = @{$keypad{$from_key}};
    my ($button_x, $button_y) = @{$keypad{$to_key}};
    my $delta_x = $button_x - $x;
    my $delta_y = $button_y - $y;
    my $x_dir = $delta_x == 0 ? 0 : $delta_x / abs($delta_x);
    my $y_dir = $delta_y == 0 ? 0 : $delta_y / abs($delta_y);

    # Prioritize left, then down, then right, then up
    # Loop twice incase any movements are skipped due to invalid position on keypad
    for my $i (0..1) {
        if ($x_dir == -1 && exists $valid_key_pos{"$button_x,$y"} && $x != $button_x) {
            $x = $button_x;
            $command_str .= "<" x abs($delta_x);
        }

        if ($y_dir == 1 && exists $valid_key_pos{"$x,$button_y"} && $y != $button_y) {
            $y = $button_y;
            $command_str .= "v" x abs($delta_y);
        }

        if ($x_dir == 1 && exists $valid_key_pos{"$button_x,$y"} && $x != $button_x) {
            $x = $button_x;
            $command_str .= ">" x abs($delta_x);
        }

        if ($y_dir == -1 && exists $valid_key_pos{"$x,$button_y"} && $y != $button_y) {
            $y = $button_y;
            $command_str .= "^" x abs($delta_y);
        }
    }

    $command_str .= "A";
    $move_memo{$from_key}{$to_key} = $command_str;

    return $command_str;
}

sub command_to_movements {
    my ($command, $keypad_ref, $valid_key_pos_ref) = @_;
    my %keypad = %{$keypad_ref};
    my %valid_key_pos = %{$valid_key_pos_ref};
    my ($x, $y) = @{$keypad{"A"}};
    my $command_str = "";

    for my $i (0..length($command) - 1) {
        my $from_key = $valid_key_pos{"$x,$y"};
        my $to_key = substr($command, $i, 1);
        my ($button_x, $button_y) = @{$keypad{$to_key}};

        $command_str .= memoized_move($from_key, $to_key, $keypad_ref, $valid_key_pos_ref);

        $x = $button_x;
        $y = $button_y;
    }

    return $command_str
}

sub calculate_cost {
    my ($command_str, $count, $start) = @_;
    #print("command: $command_str\n");

    if (length($command_str) == 1) {
        if ($command_str eq "A") {
            return 1;
        } else {
            print("IDK WHAT THIS IS, $command_str\n");
        }
    } if (length($command_str) == 2) {
        my $from = substr($command_str, 0, 1);
        my $to = substr($command_str, 1, 1);
        my $moves = memoized_move($from, $to, \%dir_keypad, \%valid_dir_key_pos);

        if ($start) {
            my $start_moves = memoized_move("A", $from, \%dir_keypad, \%valid_dir_key_pos);
            $moves = $start_moves . $moves;
        }

        my $cost = length($moves);

        if ($count <= 0) {
            return $cost;
        } else {
            return calculate_cost($moves, $count - 1, $start);
        }
    }

    my $cost = 0;

    for my $i (0..length($command_str) - 2) {
        my $command_substr = substr($command_str, $i, 2);
        $cost += calculate_cost($command_substr, $count, $start && $i == 0);
    }

    return $cost;
}

open (my $file, "<", "input.txt") or die $!;

my $total = 0;

while (my $line = <$file>) {
    chomp($line);

    my $command_str = $line;
    my $numbers = $line;
    $numbers =~ s/\D//g;
    $numbers += 0;

    my $dir_command_str = command_to_movements(
        $command_str,
        \%num_keypad,
        \%valid_num_key_pos
    );

    print("$dir_command_str\n");

    my $cost = calculate_cost($dir_command_str, 1, !!1);
    print("\nCOST: $cost\n");

    $total += length($command_str) * $numbers;
}

close ($file);
print("$total\n");
