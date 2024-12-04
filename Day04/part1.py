TARGET_STR = "XMAS"


grid = {}


def trace_string(x, y, index, x_dir, y_dir):
    if x not in grid:
        return False

    if y not in grid[x]:
        return False

    if grid[x][y] == TARGET_STR[index]:
        if index == len(TARGET_STR) - 1:
            return True
        else:
            return trace_string(x + x_dir, y + y_dir, index + 1, x_dir, y_dir)
    else:
        return False


def main():
    xs = set()
    total = 0

    with open('./input.txt') as file:
        for y, line in enumerate(file):
            line = line.strip()

            for x, char in enumerate(line):
                if x not in grid:
                    grid[x] = {}

                grid[x][y] = char

                if char == 'X':
                    xs.add((x, y))

        for coords in xs:
            x, y = coords

            for x_dir in range(-1, 2, 1):
                for y_dir in range(-1, 2, 1):
                    if x_dir == 0 and y_dir == 0:
                        continue

                    if trace_string(x, y, 0, x_dir, y_dir):
                        total += 1

    print(total)


if __name__ == '__main__':
    main()

