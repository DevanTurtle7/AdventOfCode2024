use strict;
use warnings;
use String::Util qw(trim);

my $max_block_size = 9;

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
my %spaces;

while ($index < $line_length) {
    my $size = substr($disk_map, $index, 1);

    if (!($index % 2)) {
        my $current = File->new(size => $size, id => $index / 2);
        push(@blocks, $current);
        push(@files, $current);
    } else {
        push(@blocks, $size);

        for my $i (1..$size) {
            unless (exists $spaces{$i}) {
                $spaces{$i} = $index;
            }
        }
    }

    $index++;
}

foreach my $file (reverse @files) {
    my $last_file = $#blocks - ($#blocks % 2);
    my $file_index = $last_file;

    my $id = $file->id;
    print("CHECKING ID $id\n");

    while ($file_index >= 0) {
        if ($blocks[$file_index] eq $file) {
            last;
        }

        $file_index -= 2;
    }

    if (exists $spaces{$file->size} && $spaces{$file->size} < $file_index) {
        #print("space exists\n");
        # Remove the file
        my $total_space = $file->size;

        if ($file_index > 0) {
            my $prev_block = $blocks[$file_index - 1];
            $total_space += $blocks[$file_index - 1];
        }

        if ($file_index < $#blocks) {
            $total_space += $blocks[$file_index + 1];
        }

        $blocks[$file_index] = $total_space;

        for my $space_key (1..$total_space) {
            if ((exists $spaces{$space_key} && $spaces{$space_key} > $file_index) || !exists $spaces{$space_key}) {
                $spaces{$space_key} = $file_index;
                #print("Setting HASH (A): $space_key: $file_index\n");
            }
        }

        if ($file_index < $#blocks) {
            splice(@blocks, $file_index + 1, 1);
        }

        if ($file_index > 0) {
            splice(@blocks, $file_index - 1, 1);
        }

        # Add the file back in the new space
        my $space_index = $spaces{$file->size};
        my $space = $blocks[$space_index];
        my $space_remaining = $space - $file->size;

        # Need to delete anywhere this current index is being used 
        my @deleted;

        for my $space_key (1..$space) {
            if (exists $spaces{$space_key} && $spaces{$space_key} eq $space_index) {
                delete $spaces{$space_key};
                push(@deleted, $space_key);
            }
        }

        splice(@blocks, $space_index, 1);
        splice(@blocks, $space_index, 0, $space_remaining);
        splice(@blocks, $space_index, 0, $file);
        splice(@blocks, $space_index, 0, 0);

        for my $space_key (1..$space_remaining) {
            if ((exists $spaces{$space_key} && $spaces{$space_key} > $file_index) || !exists $spaces{$space_key}) {
                $spaces{$space_key} = $space_index + 2;


                my $val = $space_index + 2;
                #print("Setting HASH (B): $space_key: $val\n");
            }
        }

        while ($space_index <= $#blocks && $#deleted >= 0) {
            my $current_space = $blocks[$space_index];

            my $deleted_index = 0;

            while ($deleted_index <= $#deleted) {
                my $space_key = $deleted[$deleted_index];

                if ($current_space >= $space_key) {
                    $spaces{$space_key} = $space_index;
                    #print("Setting HASH (C): $space_key: $space_index\n");
                    splice(@deleted, $deleted_index, 1);
                } else {
                    $deleted_index++;
                }
            }

            $space_index += 2;
        }
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
