extends MarginContainer

@export var autorun: GDScript
@export var autorun_input: ScriptInput
@export var base_dir: String = "res://work"

@onready var dir_list: ItemList = %DirList
@onready var script_list: ItemList = %ScriptList
@onready var input_list: ItemList = %InputList
@onready var output: TextEdit = %Output

#region(Selected Item Helpers)
func get_selected_text(list: ItemList) -> String:
    return list.get_item_text(list.get_selected_items()[0])

func get_selected_dir_path() -> String:
    return base_dir.path_join(get_selected_text(dir_list))

func get_selected_script_name() -> String:
    return get_selected_text(script_list)

func get_selected_script_path() -> String:
    return get_selected_dir_path().path_join(get_selected_text(script_list))

func get_selected_input_name() -> String:
    return get_selected_text(input_list)

func get_selected_input_path() -> String:
    return get_selected_dir_path().path_join(get_selected_text(input_list))
#endregion

func _ready() -> void:
    Events.output.connect(_on_output)

    if autorun and autorun_input:
        Events.output.emit("<Autorun: %s with %s>" % [ autorun.resource_path, autorun_input.resource_path ])
        (autorun.new() as DailyScript).solve(autorun_input.text)

    populate_dir_list()

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("Run"):
        if script_ui.visible:
            _on_script_save_button_pressed()
        elif input_ui.visible:
            _on_input_save_button_pressed()

        _on_run_button_pressed()

#region(UI Lists)

func populate_dir_list(select: int = 0) -> void:
    dir_list.clear()
    var dirs := DirAccess.open(base_dir)

    for dir in dirs.get_directories():
        dir_list.add_item(dir)

    if dir_list.item_count > select:
        dir_list.select(select)
        populate_file_lists()

func populate_file_lists() -> void:
    var files := DirAccess.open(get_selected_dir_path())

    script_list.clear()
    input_list.clear()

    for file in files.get_files():
        if file.ends_with(".gd"):
            script_list.add_item(file)
        else:
            input_list.add_item(file)

    if script_list.item_count > 0:
        script_list.select(0)

    if input_list.item_count > 0:
        input_list.select(0)

func _on_dir_list_item_selected(_index: int) -> void:
    populate_file_lists()

#endregion

func _on_output(message: Variant) -> void:
    output.text += str(message)
    if not output.text.ends_with("\n"):
        output.text += "\n"

func _on_run_button_pressed() -> void:
    Events.output.emit("<Running: %s with %s>" % [
        get_selected_script_name(),
        get_selected_input_name() ])

    var script := load(get_selected_script_path())
    var input := load(get_selected_input_path())

    (script.new() as DailyScript).solve(input.text)

func _on_clear_button_pressed() -> void:
    output.clear()

#region(Prompt)

@onready var prompt_ui: PanelContainer = $Prompt
@onready var prompt_value: LineEdit = $Prompt/CenterContainer/VBoxContainer/PromptValue

func prompt(placeholder: String) -> String:
    prompt_ui.show()
    prompt_value.grab_focus()
    prompt_value.text = ""
    prompt_value.placeholder_text = placeholder

    await prompt_value.text_submitted
    prompt_ui.hide()
    return prompt_value.text

#endregion

#region(New List Items)
func _on_new_directory_pressed() -> void:
    var new_dir := await prompt("Directory name...")
    var parent := DirAccess.open(base_dir)
    parent.make_dir(new_dir)
    populate_dir_list()

func _on_new_script_pressed() -> void:
    var new_file := await prompt("Script name...")
    if not new_file.ends_with(".gd"):
        new_file += ".gd"
    var file := FileAccess.open(get_selected_dir_path().path_join(new_file), FileAccess.WRITE)
    file.store_line("extends DailyScript")
    file.close()
    populate_file_lists()

func _on_new_input_pressed() -> void:
    var file_name := await prompt("Input name...")

    if not file_name.ends_with(".tres"):
        file_name += ".tres"

    var path := get_selected_dir_path().path_join(file_name)

    var input := ScriptInput.new()
    ResourceSaver.save(input, path)
    populate_file_lists()
#endregion

#region(Input Editor)

@onready var input_editor_path_label: Label = %InputEditorPathLabel

@onready var input_ui: PanelContainer = %InputUI
@onready var input_editor: TextEdit = %InputEditor

func _on_open_input_editor_pressed() -> void:
    input_editor_path_label.text = get_selected_input_path()
    var thing := ResourceLoader.load(get_selected_input_path()) as ScriptInput
    input_editor.text = thing.text
    input_ui.show()

func _on_input_save_button_pressed() -> void:
    var input := ResourceLoader.load(get_selected_input_path()) as ScriptInput
    input.text = input_editor.text
    ResourceSaver.save(input, get_selected_input_path())

func _on_input_close_button_pressed() -> void:
    input_ui.hide()
#endregion

#region(Script Editor)

@onready var script_editor_path_label: Label = %ScriptEditorPathLabel

@onready var script_ui: PanelContainer = %ScriptUI
@onready var script_editor: CodeEdit = %ScriptEditor

func _on_edit_pressed() -> void:
    script_editor_path_label.text = get_selected_script_path()
    var file := FileAccess.open(get_selected_script_path(), FileAccess.READ)
    script_editor.text = file.get_as_text()
    file.close()
    script_ui.show()

func _on_script_save_button_pressed() -> void:
    var file := FileAccess.open(get_selected_script_path(), FileAccess.WRITE)
    file.store_string(script_editor.text)
    file.close()

func _on_script_close_button_pressed() -> void:
    script_ui.hide()

func _on_script_run_button_pressed() -> void:
    _on_script_save_button_pressed()
    _on_run_button_pressed()

#endregion



