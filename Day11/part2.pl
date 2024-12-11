use strict;
use warnings;

my %stone_counts;
my @stones;

open (my $file, "<", "input.txt") or die $!;

while (my $line = <$file>) {
    chomp($line);
    my @tokens = split(" ", $line);

    foreach my $token (@tokens) {
        push(@stones, $token);

        $stone_counts{$token} += 1;
    }
}

close ($file);

my $total = 0;
my $num_blinks = 75;

for (1..$num_blinks) {
    my %new_counts;

    foreach my $stone (keys %stone_counts) {
        $stone += 0; # Force numeric context
        my $num_stones = $stone_counts{$stone} + 0;

        my $num_digits = length($stone);

        if ($stone == 0) {
            $new_counts{1} += $num_stones;
        } elsif ($num_digits % 2 == 0) {
            my $half_length = $num_digits / 2;
            my $first_half = substr($stone, 0, $half_length) + 0;
            my $second_half = substr($stone, $half_length, $num_digits) + 0;

            $new_counts{$first_half} += $num_stones;
            $new_counts{$second_half} += $num_stones;
        } else {
            $new_counts{$stone * 2024} += $num_stones;
        }
    }

    %stone_counts = %new_counts;
}

foreach my $stone (keys %stone_counts) {
    my $count = $stone_counts{$stone};

    if ($count != 0) {
        $total += $count;
    }
}

print("Total: $total\n");
