use strict;
use warnings;
use List::Util 'sum';

my @left_nums;
my %right_counts;

open (my $file, "<", "input.txt") or die $!;

while (my $line = <$file>) {
    my @nums = split(" ", $line);
    my $left = $nums[0];
    my $right = $nums[1];

    unless (exists $right_counts{$right}) {
        $right_counts{$right} = 0
    }

    push(@left_nums, $left);
    $right_counts{$right}++;
}

close ($file);

my @sim_scores = map {exists $right_counts{$_} ? $_ * $right_counts{$_} : 0} @left_nums;
my $sim_score = sum(@sim_scores);

print("Total: $sim_score\n");
