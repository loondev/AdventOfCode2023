extends DailyScript

func numbers_search(text: String) -> Array:
    return numbers_re.search_all(text).map(func(m: RegExMatch): return int(m.strings[1]))

var numbers_re := RegEx.create_from_string(r"(\d+)")

func count_winners(winning_numbers: Array, played_numbers: Array) -> int:
    var win_map := {}
    for w in winning_numbers:
        win_map[w] = 1

    var count := 0
    for p in played_numbers:
        if win_map.has(p):
            count += 1

    return count

func solve(text: String) -> void:
    var cards := {}

    for line in text.split("\n"):
        var parts := line.split(":")
        var id := parts[0].to_int()
        cards[id] = cards.get(id, 1)
        var game := parts[1].split("|") # <winning_numbers> | <played_numbers>
        var wins := count_winners(numbers_search(game[0]), numbers_search(game[1]))

        for i in range(id + 1, id + wins + 1):
            cards[i] = cards.get(i, 1) + cards[id]
            print(id, " incr ", i , " now ", cards[i])

    Events.output.emit(cards.values().reduce(func(a, b): return a + b))
