number=$1
template="
def main():
  with open('./input.txt') as file:
    pass

if __name__ == '__main__':
  main()
"

directory="Day${number}"
mkdir "$directory"
echo "$template" > "$directory/part1.py"
echo "$template" > "$directory/part2.py"
touch "$directory/input.txt"
cd "$directory"