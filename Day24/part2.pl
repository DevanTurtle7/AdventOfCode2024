use strict;
use warnings;

my %connections;

open (my $file, "<", "input.txt") or die $!;

my $reading_commands = !!0;

while (my $line = <$file>) {
    if ($line eq "\n") {
        $reading_commands = !!1;
        next;
    }

    chomp($line);

    if ($reading_commands) {
        my ($command_line, $output) = split(" -> ", $line);
        my ($input1, $command, $input2) = split(" ", $command_line);
        $connections{$input1}{$command}{$input2} = $output;
        $connections{$input2}{$command}{$input1} = $output;
    }
}

close ($file);

my %swaps;

sub swap {
    my ($output1, $output2) = @_;

    foreach my $input1 (keys %connections) {
        foreach my $command (keys %{$connections{$input1}}) {
            foreach my $input2 (keys %{$connections{$input1}{$command}}) {
                my $output = $connections{$input1}{$command}{$input2};
                if ($output eq $output1 || $output eq $output2) {
                    if ($output eq $output1) {
                        $connections{$input1}{$command}{$input2} = $output2;
                    } else {
                        $connections{$input1}{$command}{$input2} = $output1;
                    }
                }
            }
        }
    }

    $swaps{$output1} = 1;
    $swaps{$output2} = 1;
}

my $i = 1;

while ($i <= 44) {
    my $num = $i."";

    if (length($num) == 1) {
        $num = "0".$num
    }

    my $x_start = "x$num";
    my $y_start = "y$num";
    my $expected = "z$num";

    my $xor_node = $connections{$x_start}{"XOR"}{$y_start};
    my $or_node = $connections{$x_start}{"AND"}{$y_start};

    unless (exists $connections{$xor_node}{"XOR"} && exists $connections{$xor_node}{"AND"}) {
        if (exists $connections{$or_node}{"XOR"} && exists $connections{$or_node}{"AND"}) {
            swap($xor_node, $or_node);
        }
        next;
    }

    my @xor_connections = keys %{$connections{$xor_node}{"XOR"}};
    my $xor_other_node = $xor_connections[0];
    my $xor_output = $connections{$xor_node}{"XOR"}{$xor_other_node};

    if ($xor_output ne $expected) {
        swap($xor_output, $expected);
        next;
    }

    my @and_connections = keys %{$connections{$xor_node}{"AND"}};
    my $and_other_node = $and_connections[0];
    my $and_output = $connections{$xor_node}{"AND"}{$and_other_node};

    my @or_connections = keys %{$connections{$or_node}{"OR"}};
    my $or_other_node = $or_connections[0];

    if ($or_other_node ne $and_output) {
        swap($or_other_node, $and_output);
        next;
    }

    $i++;
}

my $names = join(",", sort(keys %swaps));
print("$names\n");
