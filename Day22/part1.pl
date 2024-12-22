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

my $total = 0;

while (my $line = <$file>) {
    chomp($line);
    my $secret = $line;

    for my $i (1..2000) {
        $secret = next_secret($secret);
    }
    $total += $secret;
}

close ($file);

print("$total\n");
