extends DailyScript

func solve(text: String) -> void:
    var lines := text.split("\n")

    var result := 0

    for line in lines:
        var line_parts := line.split(":")
        var power := get_power(line_parts[1])
        result += get_power(line_parts[1])

    Events.output.emit(result)

var game_re := RegEx.create_from_string(r"(?<count>\d+) (?<colour>\w+),?")

func get_power(game: String) -> int:
    var sets := game.split(";")

    var required := {}

    for s in sets:
        var cubes := game_re.search_all(s)
        for cube in cubes:
            var count := cube.get_string("count").to_int()
            var colour := cube.get_string("colour")
            required[colour] = maxi(required.get(colour, 0), count)

    return required.values().reduce(func(a, b): return a * b)
