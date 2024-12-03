EXPECTED_PREFIX = "mul("
EXPECTED_SUFFIX = ")"

# Don't want to use regex and this solution is O(n) so it's probably faster anyways

def main():
    with open('./input.txt') as file:
        total = 0

        index = 0

        before_comma = True 
        num1_str = None
        num2_str = None
        reset = False

        for line in file:
            line = line.strip()

            for char in line:
                if reset == True:
                    reset = False
                    index = 0
                    before_comma = True
                    num1_str = None
                    num2_str = None

                if index >= len(EXPECTED_PREFIX):
                    if char.isdigit():
                        if before_comma:
                            if num1_str == None:
                                num1_str = ""
                            elif len(num1_str) >= 3:
                                reset = True
                                continue

                            num1_str += char
                        else:
                            if num2_str == None:
                                num2_str = ""
                            elif len(num2_str) >= 3:
                                reset = True
                                continue

                            num2_str += char
                    elif char == "," and num1_str != None:
                        before_comma = False
                    elif char == EXPECTED_SUFFIX and num1_str != None and num2_str != None:
                        total += int(num1_str) * int(num2_str)
                        reset = True
                        continue
                    else:
                        reset = True
                        continue
                else:
                    if char == EXPECTED_PREFIX[index]:
                        index += 1
                    else:
                        reset = True
                        continue

    print(total)


if __name__ == '__main__':
    main()

