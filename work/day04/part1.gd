extends DailyScript

func numbers_search(text: String) -> Array:
    return numbers_re.search_all(text).map(func(m: RegExMatch): return int(m.strings[1]))

var numbers_re := RegEx.create_from_string(r"(\d+)")

func solve(text: String) -> void:
    var result := 0
    for line in text.split("\n"):
        var parts := line.split(":")[1].split("|")
        var winning := numbers_search(parts[0])
        var played := numbers_search(parts[1])

        var win_map := {}
        for w in winning:
            win_map[w] = 1

        var points := 0
        for p in played:
            if win_map.has(p):
                points = points * 2 if points else 1

        result += points

    Events.output.emit(result)
