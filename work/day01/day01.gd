class_name Day01
extends DailyScript

var number_strings := {
    "zero": "0",
    "one": "1",
    "two": "2",
    "three": "3",
    "four": "4",
    "five": "5",
    "six": "6",
    "seven": "7",
    "eight": "8",
    "nine": "9"
}

func solve(text: String) -> void:
    Events.output.emit("Part 1: %d" % part1(text))
    Events.output.emit("Part 2: %d" % part2(text))

# Sliding window, new window on newline
func part1(text: String) -> int:
    var first: String = ""
    var last: String = ""
    var result: int = 0

    if not text.ends_with("\n"):
        text += "\n"

    for c in text:
        if c == "\n":
            result += (first + last).to_int()
            first = ""
            last = ""
        else:
            if c.is_valid_int():
                if first == "":
                    first = c
                last = c

    return result

func part2(text: String) -> int:
    var result := 0

    for line in text.split("\n"):
        var found_first := false
        var first := ""
        var last := ""

        while line:
            if line.left(1).is_valid_int():
                if not found_first:
                    found_first = true
                    first = line.left(1)
                last = line.left(1)

            for ns: String in number_strings.keys():
                if line.begins_with(ns):
                    if not found_first:
                        found_first = true
                        first = number_strings[ns]
                    last = number_strings[ns]
                    break

            line = line.substr(1)

        result += (first + last).to_int()

    return result
