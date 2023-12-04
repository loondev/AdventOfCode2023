extends DailyScript

var re := RegEx.create_from_string(r"((?<num>\d+)|(?<sym>[^0-9.\n]))")

func solve(text: String) -> void:
    var numbers := []
    var symbols := {}

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
            var pos := m.get_start("sym")
            if symbols.has(pos):
                Events.output.emit("ERROR: %s already exists!" % pos)
            symbols[pos] = m.get_string("sym")

    var result := 0

    var check := func(n: Dictionary) -> bool:
        for i in range(n.start - 1, n.end + 1):
            for c in [ i, i + line_size, i - line_size ]:
                if c >= 0 and symbols.has(c):
                    return true

        return false

    for n in numbers:
        if check.call(n):
            result += int(n.value)

    Events.output.emit(result)
