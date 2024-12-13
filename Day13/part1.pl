use strict;
use warnings;

open (my $file, "<", "input.txt") or die $!;

my %machine;
my @machines;
my $line_num = 0;

while (my $line = <$file>) {
    chomp($line);

    if ($line_num == 0) {
        %machine = ();
    }
    
    if ($line_num == 0 || $line_num == 1) {
        $line =~ /X\+(\d+),\s*Y\+(\d+)/;
        $machine{chr(ord("a") + $line_num)} = [$1, $2];
    } elsif ($line_num == 2) {
        $line =~ /X=(\d+),\s*Y=(\d+)/;
        $machine{"prize"} = [$1, $2];
        my %hash_copy = %machine;
        push(@machines, \%hash_copy);
    }

    if ($line_num == 3) {
        $line_num = 0;
        next;
    }

    $line_num++
}

close ($file);

sub add_arrays {
    my ($arr_ref1, $arr_ref2) = @_;

    return [map {$arr_ref1->[$_] + $arr_ref2->[$_]} (0..$#$arr_ref1)];
}

my $total = 0;

foreach my $machine_ref (@machines) {
    my @dp_array = map {[(0) x 101]} 1..101;
    my @a_move = @{$machine_ref->{"a"}};
    my @b_move = @{$machine_ref->{"b"}};
    my ($prize_x, $prize_y) = @{$machine_ref->{"prize"}};
    my $min_tokens = -1;

    for my $y (0..100) {
        for my $x (0..100) {
            if ($x == 0 && $y == 0) {
                $dp_array[$y][$x] = [0, 0];
            } elsif ($x == 0) {
                $dp_array[$y][$x] = add_arrays($dp_array[$y - 1][$x], \@b_move);
            } elsif ($y == 0) {
                $dp_array[$y][$x] = add_arrays($dp_array[$y][$x - 1], \@a_move);
            } else {
                $dp_array[$y][$x] = add_arrays(\@{$dp_array[0][$x]}, \@{$dp_array[$y][0]});
            }

            my ($arm_x, $arm_y) = @{$dp_array[$y][$x]};

            if ($arm_x == $prize_x && $arm_y == $prize_y) {
                my $num_tokens = ($x * 3) + $y;

                if ($min_tokens == -1 || $num_tokens < $min_tokens) {
                    $min_tokens = $num_tokens;
                }
            }
        }
    }

    if ($min_tokens > -1) {
        $total += $min_tokens;
    }
}

print("$total\n");
