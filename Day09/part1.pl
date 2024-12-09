use strict;
use warnings;
use String::Util qw(trim);

my $disk_map;

open (my $file, "<", "input.txt") or die $!;

while (my $line = <$file>) {
    $disk_map = trim($line);
}

close ($file);

my $line_length = length($disk_map);
my $ends_with_block = !!($line_length % 2);
my $start_index = 0;
my $end_index = $line_length - 1;
my @block;
my $end_num_remaining = substr($disk_map, $end_index, 1);

while ($start_index < $end_index) {
    my $current_num = substr($disk_map, $start_index, 1);

    if (!($start_index % 2)) {
        push(@block, ($start_index / 2) x $current_num);
    } else {
        while ($current_num > 0) {
            if ($end_num_remaining == 0) {
                $end_index -= 2;
                $end_num_remaining = substr($disk_map, $end_index, 1);
            }

            my $end_num_used = 0;

            if ($end_num_remaining > $current_num) {
                $end_num_used = $current_num;
            } else {
                $end_num_used = $end_num_remaining
            }

            $current_num -= $end_num_used;
            $end_num_remaining -= $end_num_used;
            push(@block, ($end_index / 2) x $end_num_used);
        }
    }

    $start_index++;
}

if ($end_num_remaining) {
    push(@block, ($end_index / 2) x $end_num_remaining);
}

my $checksum = 0;

foreach my $i (0..$#block) {
    $checksum += $block[$i] * $i;
}

print("$checksum\n");
