use strict;
use warnings;

my %input_registers;
my @input_program;
my @input_output;

open (my $file, "<", "input.txt") or die $!;

while (my $line = <$file>) {
    if ($line eq "\n") {
        next;
    }

    chomp($line);

    if ($line =~ /Register\s+([A-Z]):\s+(\d+)/) {
        my $letter = $1;  # The captured letter
        my $number = $2;  # The captured number
        $input_registers{$letter} = $number;
    } else {
        my @tokens = split(":", $line);
        my @number_strs = split(",", $tokens[1]);
        @input_program = map { $_ + 0 } @number_strs;
    }
}

close ($file);

sub run_program {
    my ($registers_ref, $program_ref) = @_;
    my %registers = %{$registers_ref};
    my @program = @{$program_ref};
    my @output;
    my $pointer = 0;

    while ($pointer < $#program) {
        my $a_reg = $registers{"A"};
        my $binary = sprintf("%b", $a_reg);

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

    return \@output;
}

sub calculate_binary {
    my ($binary, $pointer) = @_;

    if ($pointer < 0) {
        return $binary;
    }

    for my $binary_num (0..7) {
        my $bit = sprintf("%03b", $binary_num);
        #print("$binary, $bit\n");
        my $current_binary = $binary.$bit;
        my $decimal = oct("0b$current_binary");

        my %registers = (
            A => $decimal,
            B => 0,
            C => 0,
        );

        my $output_ref = run_program(\%registers, \@input_program);
        my $num_matched = $output_ref->[0] == $input_program[$pointer];

        if ($num_matched) {
            my $possible_solution = calculate_binary($current_binary, $pointer - 1);

            if ($possible_solution) {
                return $possible_solution;
            }
        }
    }

    return !!0;
}

my $solution_binary = calculate_binary("", $#input_program);
my $decimal = oct("0b$solution_binary");
print("$decimal\n");
