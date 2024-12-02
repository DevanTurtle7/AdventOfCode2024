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

    return delta <= max_delta and delta >= min_delta


def main():
    safe_count = 0

    with open('./input.txt') as file:
        for line in file:
            line = line.strip()
            tokens = line.split()
            levels = [int(token) for token in tokens]

            inc_slope = 0
            dec_slope = 0

            for i in range(0, len(levels) - 1):
                delta = levels[i + 1] - levels[i]
                slope = get_slope(delta)

                if slope > 0:
                    inc_slope += 1
                else:
                    dec_slope += 1
                
            general_slope = 1 if inc_slope > dec_slope else -1

            if len(levels) - len(set(levels)) > 1:
                continue

            sorted = levels.copy()
            sorted.sort(reverse=general_slope == -1)
            skipped = set()
            duplicates = set()

            level_i = 0
            sorted_i = 0
            diff = 0
            skipped_index = None

            while level_i < len(levels) and sorted_i < len(sorted) and diff <= 1:
                current = levels[level_i]
                expected = sorted[sorted_i]

                if current == expected and not (level_i > 0 and current == levels[level_i - 1]):
                    level_i += 1

                    if sorted_i < len(sorted) - 1:
                        sorted_i += 1
                else:
                    if sorted_i > 0 and expected == sorted[sorted_i - 1]:
                        duplicates.add(expected)

                        if sorted_i < len(sorted) - 1:
                            sorted_i += 1
                            continue

                    if expected not in skipped:
                        skipped_index = level_i
                        level_i += 1
                        diff += 1
                    else:
                        if sorted_i < len(sorted) - 1:
                            sorted_i += 1
                        else:
                            level_i += 1

                        if skipped_index == None:
                            skipped_index = level_i

                    skipped.add(current)

            if diff > 1:
                continue
            
            if skipped_index != None:
                del levels[skipped_index]

            safe = True

            for i in range(0, len(levels) - 1):
                delta = levels[i + 1] - levels[i]

                if not is_valid(delta) or get_slope(delta) != general_slope:
                    if diff == 0 and (i == 0 or i == len(levels) - 1):
                        diff += 1
                        continue

                    safe = False
                    break
            
            if safe:
                safe_count += 1

    print(safe_count)



if __name__ == '__main__':
    main()

