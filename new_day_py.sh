number=$1

directory="Day${number}"
mkdir "$directory"
cp "templates/template.py" "$directory/part1.py"
cp "templates/template.py" "$directory/part2.py"
touch "$directory/input.txt"
