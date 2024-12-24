use strict;
use warnings;

my %connections;
my @components;

open (my $file, "<", "input.txt") or die $!;

while (my $line = <$file>) {
    chomp($line);

    my ($computer1, $computer2) = split("-", $line);
    $connections{$computer1}{$computer2} = 1;
    $connections{$computer2}{$computer1} = 1;

    my %component;
    $component{$computer1} = 1;
    $component{$computer2} = 1;

    push(@components, \%component);
}

close ($file);

my $i = 0;

while ($i < $#components) {
    my $component_ref = $components[$i];
    my $j = $i + 1;

    while ($j <= $#components) {
        my %component = %{$component_ref};
        my %next_component = %{$components[$j]};
        my $merge = !!1;

        foreach my $computer (keys %component) {
            foreach my $next_computer (keys %next_component) {
                unless ($computer eq $next_computer || exists $connections{$computer}{$next_computer}) {
                    $merge = !!0;
                }
                if (!$merge) {last;}
            }
            if (!$merge) {last;}
        }

        if ($merge) {
            foreach my $computer (keys %next_component) {
                $component_ref->{$computer} = 1;
            }

            splice(@components, $j, 1);
        } else {
            $j++;
        }
    }

    $i++;
}

my $largest = 0;
my $largest_index = 0;

for my $i (0..$#components) {
    my %component = %{$components[$i]};
    my $size = scalar keys %component;

    if ($size > $largest) {
        $largest = $size;
        $largest_index = $i;
    }
}

my $password = join(",", sort(keys %{$components[$largest_index]}));
print("$password\n");
