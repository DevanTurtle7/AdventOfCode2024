use strict;
use warnings;

my %stone_counts;
my @stones;
my $num_blinks = 75;

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

for (1..$num_blinks) {
    my %new_counts;

    while (my ($stone, $count) = each %stone_counts) {
        my $num_digits = length($stone);

        if ($stone == 0) {
            $new_counts{1} += $count;
        } elsif ($num_digits % 2 == 0) {
            my $half_length = $num_digits / 2;
            my $first_half = substr($stone, 0, $half_length) + 0;
            my $second_half = substr($stone, $half_length, $num_digits) + 0;

            $new_counts{$first_half} += $count;
            $new_counts{$second_half} += $count;
        } else {
            $new_counts{$stone * 2024} += $count;
        }
    }

    %stone_counts = %new_counts;
}

my $total = 0;
$total += $_ for values %stone_counts;

print("Total: $total\n");
