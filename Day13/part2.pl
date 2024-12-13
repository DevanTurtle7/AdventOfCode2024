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

my $total = 0;
my $additional = 10000000000000;

foreach my $machine_ref (@machines) {
    my ($a_x, $a_y) = @{$machine_ref->{"a"}};
    my ($b_x, $b_y) = @{$machine_ref->{"b"}};
    my ($prize_x, $prize_y) = @{$machine_ref->{"prize"}};
    $prize_x += $additional;
    $prize_y += $additional;

    my $det = ($a_x * $b_y) - ($a_y * $b_x);
    my $det_x = ($prize_x * $b_y) - ($prize_y * $b_x);
    my $det_y = ($a_x * $prize_y) - ($a_y * $prize_x);

    my $x = $det_x / $det;
    my $y = $det_y / $det;

    if (int($x) == $x && int($y) == $y) {
        $total += ($x * 3) + $y;
    }
}

print("$total\n");
