use strict;
use warnings;

my $head;
my $prev;

package Stone {
    use Moose;

    has 'number' => ( is => 'rw');
    has 'prev' => ( is => 'rw', 'isa' => 'Maybe[Stone]');
    has 'next' => ( is => 'rw', 'isa' => 'Maybe[Stone]');

    sub visit {
        my $self = shift;
        my $number = $self->number;
        my $num_digits = length($number);

        if ($number == 0) {
            $self->{number} = 1;
        } elsif ($num_digits % 2 == 0) {
            my $half_length = $num_digits / 2;
            my $first_half = substr($number, 0, $half_length) + 0;
            my $second_half = substr($number, $half_length, $num_digits) + 0;

            my $left = Stone->new(number => $first_half, prev => $self->prev);
            my $right = Stone->new(number => $second_half, prev => $left, next => $self->next);
            $left->{next} = $right;

            if (defined $self->prev) {
                $self->prev->{next} = $left;
            } else {
                $head = $left;
            }

            if (defined $self->next) {
                $self->next->{prev} = $right;
            }
        } else {
            $self->{number} *= 2024;
        }
    }
}

open (my $file, "<", "input.txt") or die $!;

while (my $line = <$file>) {
    chomp($line);
    my @tokens = split(" ", $line);

    foreach my $token (@tokens) {
        my $stone = Stone->new(number => $token, prev => $prev);

        unless (defined $head) {
            $head = $stone;
        } else {
            $prev->{next} = $stone;
        }

        $prev = $stone;
    }
}

close ($file);

my $num_stones = 0;
my $num_blinks = 75;

for my $i (1..$num_blinks + 1) {
    my $current = $head;
    print("$i\n");

    while ($current) {
        my $value = $current->number;
        my $next_stone = $current->next;

        if ($i == $num_blinks + 1) {
            $num_stones++;
        } else {
            $current->visit();
        }

        $current = $next_stone;
    }
}

print("$num_stones\n");
