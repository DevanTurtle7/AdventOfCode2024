def main():
    with open('./input.txt') as file:
        left_nums = []
        right_counts = {}

        for line in file:
            line = line.strip()
            tokens = line.split()
            numbers = [int(token) for token in tokens]
            left, right = numbers

            left_nums.append(left)

            if right not in right_counts:
                right_counts[right] = 1
            else:
                right_counts[right] = right_counts[right] + 1

    sim_score = 0

    for num in left_nums:
        count = 0

        if num in right_counts:
            count = right_counts[num]

        sim_score += (num * count)

    print(sim_score)

if __name__ == '__main__':
    main()
