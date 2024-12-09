use strict;
use warnings;
use String::Util qw(trim);

package Node {
    use Moose;

    has 'next_node' => (is => 'rw');
    has 'prev_node' => (is => 'rw');
    has 'id' => (is => 'rw');
    has 'space' => (is => 'rw', default => !!0);
    has 'size' => (is => 'rw');

    sub set_next {
        my ($self, $new_node) = @_;
        $self->{next_node} = $new_node;
    }

    sub set_prev {
        my ($self, $new_node) = @_;
        $self->{prev_node} = $new_node;
    }
}

my $disk_map;

open (my $file, "<", "input.txt") or die $!;

while (my $line = <$file>) {
    $disk_map = trim($line);
}

close ($file);

my $line_length = length($disk_map);
my $index = 0;
my $head;
my $prev;
my @nodes;

while ($index < $line_length) {
    my $size = substr($disk_map, $index, 1);

    unless ($head) {
        $head = Node->new(size => $size, id => $index / 2);
        $prev = $head;
        $index++;
        push(@nodes, $head);
        next;
    }

    my $current;

    if (!($index % 2)) {
        $current = Node->new(size => $size, prev_node => $prev, id => $index / 2);
        push(@nodes, $current);
    } else {
        $current = Node->new(size => $size, prev_node => $prev, space => !!1);
    }

    $prev->set_next($current);
    $prev = $current;

    $index++;
}

my $all_nodes_checked = !!0;

foreach my $node (reverse @nodes) {
    my $current = $head;
    my $space_found = !!0;

    if ($node->space) {
        $node = $node->prev_node;
        next;
    }

    while (!$space_found && $current) {
        unless ($current->space) {
            if ($current->id eq $node->id) {
                $space_found = !!0;
                last;
            } else {
                $current = $current->next_node;
                next;
            }
        }

        my $current_size = $current->size;
        my $node_size = $node->size;

        if ($current->size >= $node->size) {
            $space_found = !!1;
            last;
        }

        $current = $current->next_node;
    }

    if ($space_found) {
        my $space_remaining = $current->size - $node->size;

        # TODO: Leave empty space when end is moved
        my $empty_space = Node->new(
            size => $node->size,
            space => !!1,
            prev_node => $node->prev_node,
            next_node => $node->next_node
        );

        if (defined $node->prev_node) {
            $node->prev_node->set_next($empty_space);
        }

        if (defined $node->next_node) {
            $node->next_node->set_prev($empty_space);
        }

        if (defined $current->prev_node) {
            $current->prev_node->set_next($node);
            $node->set_prev($current->prev_node);
        }

        if (defined $current->next_node) {
            if ($space_remaining > 0) {
                my $space_left = Node->new(
                    size => $space_remaining,
                    space => !!1,
                    prev_node => $node,
                    next_node => $current->next_node
                );

                $current->next_node->set_prev($space_left);
                $node->set_next($space_left);
            } else {
                $current->next_node->set_prev($node);
                $node->set_next($current->next_node);
            }
        }
    }
}

my $checksum = 0;
my $current = $head;
my $position = 0;

while ($current) {
    if ($current->space) {
        $position += $current->size;
        $current = $current->next_node;
        next;
    }

    my $size = $current->size;

    for (my $i = $size; $i > 0; $i--) {
        $checksum += $current->id * $position;
        $position++;
    }

    $current = $current->next_node;
}

print("$checksum\n");
