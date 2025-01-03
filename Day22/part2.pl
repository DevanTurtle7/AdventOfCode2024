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
    print("$line_num\n");

    for my $i (1..2000) {
        $secret = next_secret($secret);
        my $price = substr($secret, -1, 1);
        push(@prices, $price);

        if ($#prices > 4) {
            shift(@prices);
        }

        if ($#prices < 3) {
            next;
        }

        my @changes = map {$prices[$_] - $prices[$_-1]} (1..$#prices);
        my $change_key = join(",", @changes);
        my $current_price = $prices[-1];

        unless (exists $changes{$line_num} && exists $changes{$line_num}{$change_key}) {
            $changes{$line_num}{$change_key} = 1;
            $change_profits{$change_key} += $current_price;
        }
    }

    $line_num++;
}

close ($file);

my $most_profit = -1;

foreach my $profit (values %change_profits) {
    if ($profit > $most_profit) {
        $most_profit = $profit;
    }
}

print("$most_profit\n");
