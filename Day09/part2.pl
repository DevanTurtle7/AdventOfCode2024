use strict;
use warnings;
use String::Util qw(trim);

package File {
    use Moose;

    has 'id' => (is => 'rw');
    has 'size' => (is => 'rw');
}

my $disk_map;

open (my $file, "<", "input.txt") or die $!;

while (my $line = <$file>) {
    $disk_map = trim($line);
}

close ($file);

my $line_length = length($disk_map);
my $index = 0;
my @blocks;
my @files;

while ($index < $line_length) {
    my $size = substr($disk_map, $index, 1);

    if (!($index % 2)) {
        my $current = File->new(size => $size, id => $index / 2);
        push(@blocks, $current);
        push(@files, $current);
    } else {
        push(@blocks, $size);
    }

    $index++;
}

foreach my $file (reverse @files) {
    my $last_file = $#blocks - ($#blocks % 2);
    my $file_index = $last_file;

    while ($file_index >= 0) {
        if ($blocks[$file_index] eq $file) {
            last;
        }

        $file_index -= 2;
    }

    my $space_found = !!0;
    my $space_index = 1;

    while (!$space_found && $space_index < $file_index) {
        if ($blocks[$space_index] >= $file->size) {
            $space_found = !!1;
            last;
        }

        $space_index += 2;
    }


    if ($space_found) {
        # Remove the file
        my $total_space = $file->size;

        if ($file_index > 0) {
            my $prev_block = $blocks[$file_index - 1];
            $total_space += $blocks[$file_index - 1];
        }

        if ($file_index < $#files) {
            $total_space += $blocks[$file_index + 1];
        }

        $blocks[$file_index] = $total_space;

        if ($file_index < $#files) {
            splice(@blocks, $file_index + 1, 1);
        }

        if ($file_index > 0) {
            splice(@blocks, $file_index - 1, 1);
        }

        # Add the file back in the new space
        my $space = $blocks[$space_index];
        my $space_remaining = $space - $file->size;

        splice(@blocks, $space_index, 1);
        splice(@blocks, $space_index, 0, $space_remaining);
        splice(@blocks, $space_index, 0, $file);
        splice(@blocks, $space_index, 0, 0);
    }
}

my $checksum = 0;
my $position = 0;

foreach my $block (@blocks) {
    if ($block->isa('File')) {
        for my $i (1..$block->size) {
            $checksum += $block->id * $position;
            $position++;
        }
    } else {
        unless ($block eq 0) {
            $position += $block;
        }
    }
}

print("$checksum\n");
