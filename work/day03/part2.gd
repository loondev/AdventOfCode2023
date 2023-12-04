extends DailyScript

var re := RegEx.create_from_string(r"((?<num>\d+)|(?<gear>\*))")

func solve(text: String) -> void:
    var numbers := []
    var gears   := {}

    var matches := re.search_all(text)
    var line_size := text.find("\n") + 1

    for m: RegExMatch in matches:
        if m.names.has("num"): # Number
            numbers.push_back({
                "start": m.get_start("num"),
                "end": m.get_end("num"),
                "value": m.get_string("num")
            })
        else: # Symbol
            var pos := m.get_start("gear")
            if gears.has(pos):
                Events.output.emit("ERROR: %s already exists!" % pos)
            gears[pos] = []

    var attach_gears := func(n: Dictionary) -> void:
        var seen := {}
        for i in range(n.start - 1, n.end + 1):
            for c in [ i, i + line_size, i - line_size ]:
                if c >= 0 and not seen.has(c) and gears.has(c):
                    seen[c] = 1
                    gears[c].push_back(n.value)

    for n in numbers:
        attach_gears.call(n)

    var result := 0

    for g: Array in gears.values():
        if g.size() == 2:
            result += int(g[0]) * int(g[1])

    Events.output.emit(result)
