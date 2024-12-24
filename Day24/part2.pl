use strict;
use warnings;

my %values;
my @stack;
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
    $connections{$input1}{$output} = 1;
    $connections{$input2}{$output} = 1;
    $i = 0;
}

sub get_connections {
    my ($current, $expected, $connections_ref, $connected_wires) = @_;
    my %all_connections = %$connections_ref;
    $connected_wires->{$current} = 1;

    if (substr($current, 0, 1) eq "z") {
        return;
    }

    foreach my $connect (keys %{$connections{$current}}) {
        get_connections($connect, $expected, $connections_ref, $connected_wires);
    }
}

my %invalid_wires;

for my $i ("00".."44") {
    my $expected = "z$i";
    my %new_connections;

    for my $key (keys %connections) {
        for my $sub_key (keys %{$connections{$key}}) {
            $new_connections{$key}{$sub_key} = 1;
        }
    }

    if (exists $values{"x$i"}) {
        my $invalid_connection = !!0;
        my %connected_wires;
        get_connections("x$i", $expected, \%new_connections, \%connected_wires);

        foreach my $wire (keys %connected_wires) {
            print("x$i IS CONNECTED TO $wire\n");
            if (substr($wire, 0, 1) eq "z") {
                if ($wire ne $expected) {
                    #print("Invalid connection from x$i to $wire\n");
                    $invalid_connection = !!1;
                }
            }
        }

        unless ($invalid_connection) {
            print("All valid for x$i\n");
            next;
        }

        foreach my $wire (keys %connected_wires) {
            my %wire_connections;
            get_connections($wire, $expected, \%new_connections, \%wire_connections);
            unless (exists $wire_connections{$expected}) {
                print("Wire $wire is not connected to expected wire $expected\n");
            } else {
                print("Wire $wire is fine\n");
            }
        }
    }
}
