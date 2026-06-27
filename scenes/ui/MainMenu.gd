extends Control

const AudiowideFont = preload("res://assets/fonts/Audiowide/Audiowide-Regular.ttf")
const HUB_SCENE: String = "res://scenes/world/Hub.tscn"

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var ui_theme := Theme.new()
	ui_theme.default_font = AudiowideFont
	theme = ui_theme

	$MenuCenter/Menu/NewGameButton.pressed.connect(_on_new_game)
	$MenuCenter/Menu/ContinueButton.pressed.connect(_on_continue)
	$MenuCenter/Menu/LoadButton.pressed.connect(_on_load)
	$MenuCenter/Menu/QuitButton.pressed.connect(_on_quit)
	$NewGameCenter/NewGame/Buttons/CreateButton.pressed.connect(_on_create)
	$NewGameCenter/NewGame/Buttons/CancelButton.pressed.connect(_show_menu)
	$LoadCenter/Load/BackButton.pressed.connect(_show_menu)

	_refresh_availability()
	_show_menu()

func _refresh_availability() -> void:
	var has_saves: bool = not SaveSystem.list_saves().is_empty()
	$MenuCenter/Menu/ContinueButton.disabled = not has_saves
	$MenuCenter/Menu/LoadButton.disabled = not has_saves

func _show_menu() -> void:
	$MenuCenter.visible = true
	$NewGameCenter.visible = false
	$LoadCenter.visible = false

func _on_new_game() -> void:
	$NewGameCenter/NewGame/NameEdit.text = "New Save"
	$MenuCenter.visible = false
	$NewGameCenter.visible = true

func _on_create() -> void:
	var save_name: String = $NewGameCenter/NewGame/NameEdit.text.strip_edges()
	if save_name == "":
		save_name = "Save"
	SaveSystem.new_game(save_name)
	_go_to_hub()

func _on_continue() -> void:
	var saves: Array = SaveSystem.list_saves()
	if saves.is_empty():
		return
	SaveSystem.load_game(saves[0]["name"])
	_go_to_hub()

func _on_load() -> void:
	_populate_save_list()
	$MenuCenter.visible = false
	$LoadCenter.visible = true

func _populate_save_list() -> void:
	var list: VBoxContainer = $LoadCenter/Load/SaveList
	for child: Node in list.get_children():
		child.queue_free()
	for save: Dictionary in SaveSystem.list_saves():
		var completed: int = save.get("completed_levels", []).size()
		var button := Button.new()
		button.text = "%s  (%d cleared)" % [save.get("name", "?"), completed]
		var save_name: String = save.get("name", "")
		button.pressed.connect(func() -> void: _load_named(save_name))
		list.add_child(button)

func _load_named(save_name: String) -> void:
	if SaveSystem.load_game(save_name):
		_go_to_hub()

func _on_quit() -> void:
	get_tree().quit()

func _go_to_hub() -> void:
	get_tree().change_scene_to_file(HUB_SCENE)
