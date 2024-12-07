use strict;
use warnings;
use String::Util qw(trim);

sub operate {
    my ($nums_ref, $index, $total, $target) = @_;
    my @nums = @$nums_ref;

    if ($index > $#nums) {
        return $total eq $target;
    } elsif ($total > $target) {
        return 0;
    } else {
        my $num = $nums[$index];
        my $add_result = operate($nums_ref, $index + 1, $total + $num, $target);
        my $multiply_result = operate($nums_ref, $index + 1, $total * $num, $target);

        return $add_result || $multiply_result;
    }
}

open (my $file, "<", "input.txt") or die $!;

my $total = 0;

while (my $line = <$file>) {
    $line = trim($line);
    my @tokens = split(":", $line);
    my $target = $tokens[0];
    my @nums = split(" ", $tokens[1]);

    if (operate(\@nums, 1, $nums[0], $target)) {
        $total += $target;
    }
}

close ($file);

print("$total\n");
