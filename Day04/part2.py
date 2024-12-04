
def main():
    grid = {}
    a_coords = set()
    total = 0

    with open('./input.txt') as file:
        for y, line in enumerate(file):
            line = line.strip()

            for x, char in enumerate(line):
                if x not in grid:
                    grid[x] = {}

                grid[x][y] = char

                if char == 'A':
                    a_coords.add((x, y))

    for coords in a_coords:
        x, y = coords
        diag_neighbors = {}

        for x_dir in range(-1, 2, 2):
            for y_dir in range(-1, 2, 2):
                current_x = x + x_dir
                current_y = y + y_dir

                if current_x not in grid:
                   continue 

                if current_y not in grid[current_x]:
                    continue

                char = grid[current_x][current_y]

                if char not in diag_neighbors:
                    diag_neighbors[char] = 0

                diag_neighbors[char] = diag_neighbors[char] + 1

        if "S" not in diag_neighbors or "M" not in diag_neighbors:
            continue

        if diag_neighbors["S"] != 2 or diag_neighbors["M"] != 2:
            continue

        if grid[x + 1][y + 1] == grid[x - 1][y - 1]:
            continue

        total += 1

    print(total)



if __name__ == '__main__':
    main()

