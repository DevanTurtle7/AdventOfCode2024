number=$1

directory="Day${number}"
mkdir "$directory"
cp "templates/template.pl" "$directory/part1.pl"
cp "templates/template.pl" "$directory/part2.pl"
touch "$directory/input.txt"
