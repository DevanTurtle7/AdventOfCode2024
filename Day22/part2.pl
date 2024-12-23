use strict;
use warnings;

sub mix {
    my ($secret, $num) = @_;
    return $secret ^ $num;
}

sub prune {
    my ($secret) = @_;
    return $secret % 16777216;
}

my %secret_memo;

sub next_secret {
    my ($secret) = @_;
    my $init_value = $secret;

    if (exists $secret_memo{$secret}) {
        return $secret_memo{$secret}
    }

    $secret = prune(mix($secret, $secret * 64));
    $secret = prune(mix($secret, int($secret / 32)));
    $secret = prune(mix($secret, $secret * 2048));

    $secret_memo{$init_value} = $secret;
    return $secret;
}

open (my $file, "<", "input.txt") or die $!;

my %changes;
my %change_profits;
my $line_num = 0;

while (my $line = <$file>) {
    chomp($line);
    my $secret = $line;
    my @prices;
    my %ranges;
    print("$line_num\n");

    for my $i (1..2000) {
        $secret = next_secret($secret);
        my $price = substr($secret, -1, 1);
        push(@prices, $price);

        if ($#prices > 4) {
            shift(@prices);
        }

        my @changes = map {$prices[$_] - $prices[$_-1]} (1..$#prices);
        my $change_key = join(",", @changes);

        if ($change_key eq "-2,1,-1,3") {
            my $prices = join(",", @prices);
        }

        if (exists $ranges{$change_key}) {
            if ($ranges{$change_key} < $prices[-1]) {
                $ranges{$change_key} = $prices[-1];
            }
        } else {
            $ranges{$change_key} = $prices[-1];
        }
    }

    foreach my $change_key (keys %ranges) {
        unless (exists $changes{$line_num} && exists $changes{$line_num}{$change_key}) {
            $changes{$line_num}{$change_key} = 1;
            $change_profits{$change_key} += $ranges{$change_key};
        }
    }

    $line_num++;
}

close ($file);

foreach my $line_num (keys %changes) {
    foreach my $change_key (keys %{$changes{$line_num}}) {
    }
}

my $most_profit = -1;

foreach my $profit (values %change_profits) {
    if ($profit > $most_profit) {
        $most_profit = $profit;
    }
}

print("$most_profit\n");
