use strict;
use warnings;

my %colors;
my %memo;
my @towels;

open (my $file, "<", "input.txt") or die $!;

my $reading_towels = !!0;

while (my $line = <$file>) {
    if ($line eq "\n") {
        $reading_towels = !!1;
        next;
    }
    chomp($line);

    if ($reading_towels) {
        push(@towels, $line);
    } else {
        my @stripes = split(", ", $line);

        foreach my $stripe (@stripes) {
            my $color = substr($stripe, 0, 1);

            if (exists $colors{$color}) {
                push(@{$colors{$color}}, $stripe);
            } else {
                $colors{$color} = [$stripe];
            }
        }
    }
}

close ($file);

sub possible_designs {
    my ($design) = @_;
    my $color = substr($design, 0, 1);

    if ($design eq "") {
        return 1;
    }

    if (exists $memo{$design}) {
        return $memo{$design};
    }

    unless (exists $colors{$color}) {
        return 0;
    }

    my @options = @{$colors{$color}};

    if ($#options < 0) {
        return 0;
    }

    my $num_designs = 0;

    foreach my $option (@options) {
        my $option_length = length($option);
        my $current_section = substr($design, 0, $option_length);

        if ($current_section eq $option) {
            my $remaining_design = substr($design, $option_length, length($design) - $option_length);
            my $result = possible_designs($remaining_design);
            $memo{$remaining_design} = $result;
            $num_designs += $result;
        }
    }

    return $num_designs;
}

my $total = 0;

foreach my $towel (@towels) {
    $total += possible_designs($towel);
}

print("$total\n");
