use strict;
use warnings;
use List::Util 'sum';

open (my $file, "<", "input.txt") or die $!;

my @left_nums;
my @right_nums;

while (my $line = <$file>) {
    my @nums = split(" ", $line);
    my $left = $nums[0];
    my $right = $nums[1];

    push(@left_nums, $left);
    push (@right_nums, $right);
}

close ($file);

@left_nums = sort(@left_nums);
@right_nums = sort(@right_nums);

my @diffs = map {abs($left_nums[$_] - $right_nums[$_])} (0..$#left_nums);
my $total = sum(@diffs);

print("Total: $total\n");
