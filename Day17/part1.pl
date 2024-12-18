use strict;
use warnings;

my %registers;
my @program;
my @output;

open (my $file, "<", "input.txt") or die $!;

while (my $line = <$file>) {
    if ($line eq "\n") {
        next;
    }

    chomp($line);

    if ($line =~ /Register\s+([A-Z]):\s+(\d+)/) {
        my $letter = $1;  # The captured letter
        my $number = $2;  # The captured number
        $registers{$letter} = $number;
    } else {
        my @tokens = split(":", $line);
        my @number_strs = split(",", $tokens[1]);
        @program = map { $_ + 0 } @number_strs;
    }
}

close ($file);

my $pointer = 0;

while ($pointer < $#program) {
    my $opcode = $program[$pointer];
    my $literal_operand = $program[$pointer + 1];
    my $combo_operand = $literal_operand;
    my $skip_jump = !!0;

    $combo_operand = $registers{"A"} if $literal_operand == 4;
    $combo_operand = $registers{"B"} if $literal_operand == 5;
    $combo_operand = $registers{"C"} if $literal_operand == 6;

    if ($opcode == 0) {
        $registers{"A"} = int($registers{"A"} / (2 ** $combo_operand));
    } elsif ($opcode == 1) {
        $registers{"B"} = ($registers{"B"} + 0) ^ ($literal_operand + 0);
    } elsif ($opcode == 2) {
        $registers{"B"} = $combo_operand % 8;
    } elsif ($opcode == 3) {
        if ($registers{"A"} != 0) {
            $pointer = $literal_operand;
            $skip_jump = !!1;
        }
    } elsif ($opcode == 4) {
        $registers{"B"} = ($registers{"B"} + 0) ^ ($registers{"C"} + 0);
    } elsif ($opcode == 5) {
        push(@output, $combo_operand % 8);
    } elsif ($opcode == 6) {
        $registers{"B"} = int($registers{"A"} / (2 ** $combo_operand));
    } elsif ($opcode == 7) {
        $registers{"C"} = int($registers{"A"} / (2 ** $combo_operand));
    }

    unless ($skip_jump) {
        $pointer += 2;
    }
}

my $output_str = join(",", @output);
print("$output_str\n");
