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


def is_safe(levels, slope):
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

    return safe


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

            safe = False 

            if is_safe(levels, general_slope):
                safe = True
            else:
                for i in range(0, len(levels)):
                    sliced = levels[0:i] + levels[i+1:len(levels)]
                    if is_safe(sliced, general_slope):
                        safe = True
                        break

            if safe:
                safe_count += 1

    print(safe_count)



if __name__ == '__main__':
    main()

