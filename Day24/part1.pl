use strict;
use warnings;

my %values;
my @stack;

open (my $file, "<", "input.txt") or die $!;

my $reading_commands = !!0;

while (my $line = <$file>) {
    if ($line eq "\n") {
        $reading_commands = !!1;
        next;
    }
    chomp($line);

    if ($reading_commands) {
        push(@stack, $line);
    } else {
        my ($wire, $value) = split(": ", $line);
        $values{$wire} = $value;
    }

}

close ($file);
my $i = 0;

while ($#stack >= 0) {
    my $line = $stack[$i];
    my ($command_line, $output) = split(" -> ", $line);
    my ($input1, $command, $input2) = split(" ", $command_line);

    unless (exists $values{$input1} && exists $values{$input2}) {
        $i++;
        next;
    }

    splice(@stack, $i, 1);
    my $value1 = !!$values{$input1};
    my $value2 = !!$values{$input2};
    my $result;

    if ($command eq "AND") {
        $result = $value1 && $value2;
    } elsif ($command eq "OR") {
        $result = $value1 || $value2;
    } elsif ($command eq "XOR") {
        $result = $value1 ^ $value2;
    }

    $values{$output} = $result + 0;
    $i = 0;
}

my $binary_str = "";

for my $i ("00".."45") {
    if (exists $values{"z$i"}) {
        $binary_str = $values{"z$i"}.$binary_str;
    }
}

my $decimal = oct("0b$binary_str");
print("$decimal\n");
