MIN_ABS_DELTA = 1
MAX_ABS_DELTA = 3

def main():
    safe_count = 0

    with open('./input.txt') as file:
        for line in file:
            line = line.strip()
            tokens = line.split()
            levels = [int(token) for token in tokens]

            first_delta = levels[1] - levels[0]

            if first_delta == 0:
                continue

            slope = first_delta / abs(first_delta)
            min_delta = min(MIN_ABS_DELTA * slope, MAX_ABS_DELTA * slope)
            max_delta = max(MIN_ABS_DELTA * slope, MAX_ABS_DELTA * slope)
            safe = True
            i = 0

            while i < len(levels) - 1:
                delta = levels[i + 1] - levels[i]

                if delta > max_delta or delta < min_delta:
                    safe = False
                    break

                i += 1

            if safe:
                safe_count += 1

    print(safe_count)

if __name__ == '__main__':
    main()

