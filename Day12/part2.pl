use strict;
use warnings;

my $RIGHT = 'right';
my $LEFT = 'left';
my $UP = 'up';
my $DOWN = 'down';

my %grid;
my %visited;
my %sides;

my $minY = 0;
my $minX = 0;
my $maxX;
my $maxY;

my $y = 0;

package Side {
    use Moose;

    has x_dir => (is => 'rw');
    has y_dir => (is => 'rw');
    has plots => (
        is => 'rw',
        isa => 'ArrayRef',
        default => sub { [] }
    );

    sub join {
        my ($self, $other_line) = @_;
        my $plots_ref = $self->plots;
        my $other_plots_ref = $other_line->plots;
        my @plots = @$plots_ref;
        my @other_plots = @$other_plots_ref;
        my $x_dir = $self->x_dir;
        my $y_dir = $self->y_dir;

        push(@plots, @other_plots);

        $self->{plots} = \@plots;

        foreach my $coords_ref (@other_plots) {
            my ($x, $y) = @$coords_ref;
            $sides{"$x,$y"}{"$x_dir,$y_dir"} = $self;
        }
    }
}

sub valid_coords {
    my ($x, $y) = @_;

    return $x >= $minX && $x <= $maxX && $y >= $minY &&  $y <= $maxY;
}

sub get_fencing {
    my %empty;
    %sides = %empty;
    my ($start_x, $start_y) = @_;
    my @to_visit = ([$start_x, $start_y]);
    my $plant = $grid{$start_x}{$start_y};
    my %checked;
    my %all_coords;
    my %neighbors;

    my $num_plots = 1;
    my $num_fencing = 0;

    $checked{$start_x}{$start_y} = 1;

    while ($#to_visit >= 0) {
        my $coords_ref = pop @to_visit;
        my ($x, $y) = @$coords_ref;
        my $current_fencing = 4;
        $visited{$x}{$y} = 1;
        $all_coords{$x}{$y} = 1;

        for my $add_x (-1..1) {
            for my $add_y (-1..1) {
                if (($add_x == 0 && $add_y == 0) || abs($add_x) == abs($add_y)) {
                    next;
                }
                my $x_str = $x."";
                my $y_str = $y."";
                my $key = "$x_str,$y_str";
                my $dir_key = "$add_x,$add_y";

                $sides{$key}{$dir_key} = Side->new(
                    x_dir => $add_x,
                    y_dir => $add_y,
                    plots => [[$x, $y]]
                );

                my $neighbor_x = $x + $add_x;
                my $neighbor_y = $y + $add_y;

                if (!valid_coords($neighbor_x, $neighbor_y)) {
                    next;
                }

                if ($grid{$neighbor_x}{$neighbor_y} eq $plant) {
                    $current_fencing--;
                    delete $sides{$key}{$dir_key};
                    my $x_delta = $x - $neighbor_x;
                    my $y_delta = $y - $neighbor_y;
                    my $delta_key = "$x_delta,$y_delta";

                    $neighbors{$key}{$delta_key} = 1;

                    if (!exists $checked{$neighbor_x}{$neighbor_y}) {
                        push(@to_visit, [$neighbor_x, $neighbor_y]);
                        $checked{$neighbor_x}{$neighbor_y} = 1;
                        $num_plots++;
                    }
                }
            }
        }

        $num_fencing += $current_fencing;

    }

    foreach my $key (keys %neighbors) {
        my ($x, $y) = split(",", $key);
        my %sides_hash = %{$sides{$key}};

        foreach my $side_dir (keys %sides_hash) {
            my $side = $sides{$key}{$side_dir};
            my ($x_dir, $y_dir) = split(",", $side_dir);

            for (my $i = -1; $i <= 1; $i += 2) {
                my $inverse_x = $x + ($y_dir * $i);
                my $inverse_y = $y + ($x_dir * $i);
                my $inverse = [$inverse_x, $inverse_y];
                my $inverse_key = "$inverse_x,$inverse_y";
                my $x_delta = $x - $inverse_x;
                my $y_delta = $y - $inverse_y;
                my $delta_key = "$x_delta,$y_delta";

                if (exists $neighbors{$key}{$delta_key} && exists $sides{$inverse_key}{$side_dir}) {
                    my $neighbor_side = $sides{$inverse_key}{$side_dir};
                    $side->join($neighbor_side); }
            }

        }
    }

    my %unique_sides;

    foreach my $key (keys %sides) {
        my %sides_hash = %{$sides{$key}};
        
        foreach my $side_dir (keys %sides_hash) {
            my $side = $sides{$key}{$side_dir};

            $unique_sides{$side} = $side;
        }
    }

    foreach my $side_key (keys %unique_sides) {
        my $side = $unique_sides{$side_key};
        my @plots = @{$side->plots};

        foreach my $plot (@plots) {
            my ($x, $y) = @{$plot};
        }
    }

    my $num_sides = keys %unique_sides;
    print("PLANT: $plant, $num_sides\n");

    return ($num_plots, $num_sides);
}

open (my $file, "<", "input.txt") or die $!;

while (my $line = <$file>) {
    chomp ($line);
    $maxX = length($line) - 1;

    for my $x (0..$maxX) {
        my $char = substr($line, $x, 1);
        $grid{$x}{$y} = $char;
    }

    $y++;
}

close ($file);

$maxY = $y - 1;

my $total = 0;

foreach my $x (keys %grid) {
    my $y_hash_ref = $grid{$x};
    my %y_hash = %$y_hash_ref;

    foreach my $y (keys %y_hash) {
        unless (exists $visited{$x} && exists $visited{$x}{$y}) {
            my ($num_plots, $num_sides) = get_fencing($x, $y);
            $total += $num_plots * $num_sides;
        }
    }
}

print("$total\n");
