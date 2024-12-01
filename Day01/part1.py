def main():
    with open('./input.txt') as file:
        ordered_left = []
        ordered_right = []

        for line in file:
            line = line.strip()
            tokens = line.split()
            numbers = [int(token) for token in tokens]
            left, right = numbers

            ordered_left.append(left)
            ordered_right.append(right)

    ordered_left.sort()
    ordered_right.sort()

    diffs = 0

    for i in range(0, len(ordered_left)):
        diffs += abs(ordered_left[i] - ordered_right[i])

    print(diffs)


if __name__ == '__main__':
    main()

