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
    $valid_num_key_pos{"$x,$y"} = 1;
}

foreach my $key (keys %dir_keypad) {
    my ($x, $y) = @{$dir_keypad{$key}};
    $valid_dir_key_pos{"$x,$y"} = 1;
}

sub command_to_movements {
    my ($command, $keypad_ref, $valid_key_pos_ref) = @_;
    my %keypad = %{$keypad_ref};
    my %valid_key_pos = %{$valid_key_pos_ref};
    my ($x, $y) = @{$keypad{"A"}};
    my $command_str = "";

    for my $i (0..length($command) - 1) {
        my $char = substr($command, $i, 1);
        my ($button_x, $button_y) = @{$keypad{$char}};
        my $delta_x = $button_x - $x;
        my $delta_y = $button_y - $y;
        my $x_dir = $delta_x == 0 ? 0 : $delta_x / abs($delta_x);
        my $y_dir = $delta_y == 0 ? 0 : $delta_y / abs($delta_y);
        my $x_char = $x_dir == -1 ? "<" : ">";
        my $y_char = $y_dir == -1 ? "^" : "v";

        for my $i (0..1) {
            if ($x_dir == -1 && exists $valid_key_pos{"$button_x,$y"} && $x != $button_x) {
                $x = $button_x;
                $command_str .= $x_char x abs($delta_x);
            }

            if ($y_dir == 1 && exists $valid_key_pos{"$x,$button_y"} && $y != $button_y) {
                $y = $button_y;
                $command_str .= $y_char x abs($delta_y);
            }

            if ($x_dir == 1 && exists $valid_key_pos{"$button_x,$y"} && $x != $button_x) {
                $x = $button_x;
                $command_str .= $x_char x abs($delta_x);
            }

            if ($y_dir == -1 && exists $valid_key_pos{"$x,$button_y"} && $y != $button_y) {
                $y = $button_y;
                $command_str .= $y_char x abs($delta_y);
            }
        }

        $command_str .= "A";
    }

    return $command_str;
}

open (my $file, "<", "input.txt") or die $!;

my $total = 0;

while (my $line = <$file>) {
    chomp($line);
    my $command_str = $line;
    my $numbers = $line;
    $numbers =~ s/\D//g;
    $numbers += 0;

    for my $i (0..2) {
        $command_str = command_to_movements(
            $command_str,
            $i == 0 ? \%num_keypad : \%dir_keypad,
            $i == 0 ? \%valid_num_key_pos : \%valid_dir_key_pos
        );
        print("$command_str\n");
    }

    my $len = length($command_str);
    print("$len, $numbers\n");
    $total += length($command_str) * $numbers;
}

close ($file);
print("$total\n");
