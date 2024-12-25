use strict;
use warnings;

my $width = 5;
my $height = 5;
my %keys;
my %locks;
my @current;
my $current_lock = !!0;
my $i = 0;

open (my $file, "<", "input.txt") or die $!;

while (my $line = <$file>) {
    if ($line eq "\n") {
        my $current_str = join(",", @current);

        if ($current_lock) {
            $locks{$current_str} = 1;
        } else {
            $keys{$current_str} = 1;
        }

        @current = (0) x $width;
        $i = 0;
        next;
    }

    chomp ($line);

    if ($i == 0 || $i == $height + 1) {
        if ($line eq "#" x $width) {
            $current_lock = $i == 0;
        }

        $i++;
        next;
    }

    for my $j (0..$width - 1) {
        my $char = substr($line, $j, 1);
        $current[$j] += $char eq "#" ? 1 : 0;
    }

    $i++;
}

my $current_str = join(",", @current);

if ($current_lock) {
    $locks{$current_str} = 1;
} else {
    $keys{$current_str} = 1;
}

close ($file);
my $total = 0;

foreach my $key_str (keys %keys) {
    my @key = split(",", $key_str);
    foreach my $lock_str (keys %locks) {
        my @lock = split(",", $lock_str);
        my $num_invalid = grep {$key[$_] + $lock[$_] > $height} (0..$width - 1);

        if ($num_invalid == 0) {
            $total++;
        }
    }
}

print("$total\n");