MIN_ABS_DELTA = 1
MAX_ABS_DELTA = 3

def get_slope(num):
    if num == 0:
        return 0

    return num / abs(num)

def is_valid(delta):
    slope = get_slope(delta)

    if slope == 0:
        return False
    
    min_delta = min(MIN_ABS_DELTA * slope, MAX_ABS_DELTA * slope)
    max_delta = max(MIN_ABS_DELTA * slope, MAX_ABS_DELTA * slope)

    return delta <= max_delta or delta >= min_delta


def main():
    safe_count = 0

    with open('./input.txt') as file:
        for line in file:
            line = line.strip()
            tokens = line.split()
            levels = [int(token) for token in tokens]

            deltas = []
            i = 0
            level_removed = False

            while i < len(levels) - 1:
                current_delta = levels[i + 1] - levels[i]

                # Try removing current and next
                if len(deltas) == 0:
                    deltas.append(current_delta)
                    continue

                prev_delta = deltas[-1]
                prev_slope = get_slope(prev_delta)
                current_slope = get_slope(current_delta)

                if prev_slope != current_slope or not is_valid(current_delta):
                    print("Theres an error", prev_delta, current_delta, is_valid(current_delta))

                deltas.append(current_delta)
                print(deltas)

                i += 1

    print(safe_count)

if __name__ == '__main__':
    main()

