extends DailyScript

func solve(text: String) -> void:
    var lines := text.split("\n")

    var sum := 0

    for line in lines:
        var line_parts = line.split(":")
        var id := line_parts[0].to_int()

        if is_possible(line_parts[1]):
            sum += id

    Events.output.emit(sum)

var game_re := RegEx.create_from_string(r"(?<count>\d+) (?<colour>\w+),?")

var limits = {
    "red": 12,
    "green": 13,
    "blue": 14,
}

func is_possible(game: String) -> bool:
    var sets := game.split(";")

    for s in sets:
        var cubes := game_re.search_all(s)
        for cube in cubes:
            var count := cube.get_string("count").to_int()
            var colour := cube.get_string("colour")

            if count > limits.get(colour):
                return false

    return true
