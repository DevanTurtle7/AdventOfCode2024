use strict;
use warnings;
use List::Util qw(all min max sum any);

my $count = 0;

sub is_safe {
    my @levels = @_;

    my @slopes = map {
        my $delta = $levels[$_ + 1] - $levels[$_];
        $delta == 0 ? 0 : $delta / abs($delta);
    } (0..$#levels - 1);

    my $slope = sum(@slopes) > 0 ? 1 : -1;
    my @limits = (1 * $slope, 3 * $slope);
    my $min_slope = min(@limits);
    my $max_slope = max(@limits);

    return all {
        my $delta = $levels[$_ + 1] - $levels[$_];
        $delta <= $max_slope && $delta >= $min_slope;
    } (0..$#levels - 1);
}

open (my $file, "<", "input.txt") or die $!;

while (my $line = <$file>) {
    my @levels = split(" ", $line);
   
    if (is_safe(@levels)) {
        $count++;
    } else {
        my $safe_with_removal = any {
            my $remove_index = $_;
            my @levels_copy = map {$_ eq $remove_index ? () : $_} (0..$#levels);
            is_safe(@levels_copy);
        } (0..$#levels);

        if ($safe_with_removal) {
            $count++;
        }
    }
}

close ($file);

print("$count\n");

