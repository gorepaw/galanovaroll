extends Node

# Permanent, cross-session progression. Each game is one JSON file in
# user://saves/. There is no slot limit — the menu lists whatever exists.
# God levels are NOT stored here; they are per-level runtime state. What
# persists is which levels have been completed.

const SAVE_DIR: String = "user://saves/"

var current_save: Dictionary = {}

func _ready() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)

func has_current() -> bool:
	return not current_save.is_empty()

func new_game(display_name: String) -> void:
	var now: int = int(Time.get_unix_time_from_system())
	current_save = {
		"name": display_name,
		"completed_levels": [],
		"created_unix": now,
		"updated_unix": now,
	}
	save_current()

func load_game(display_name: String) -> bool:
	var data: Dictionary = _read_save(_path_for(display_name))
	if data.is_empty():
		return false
	current_save = data
	return true

func save_current() -> void:
	if current_save.is_empty():
		return
	current_save["updated_unix"] = int(Time.get_unix_time_from_system())
	var file := FileAccess.open(_path_for(current_save["name"]), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(current_save))
		file.close()

func list_saves() -> Array:
	var saves: Array = []
	var dir := DirAccess.open(SAVE_DIR)
	if dir == null:
		return saves
	dir.list_dir_begin()
	var f: String = dir.get_next()
	while f != "":
		if not dir.current_is_dir() and f.ends_with(".json"):
			var data: Dictionary = _read_save(SAVE_DIR + f)
			if not data.is_empty():
				saves.append(data)
		f = dir.get_next()
	dir.list_dir_end()
	saves.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.get("updated_unix", 0) > b.get("updated_unix", 0))
	return saves

func mark_level_completed(level_id: int) -> void:
	if current_save.is_empty():
		return
	var completed: Array = current_save.get("completed_levels", [])
	if not completed.has(level_id):
		completed.append(level_id)
		current_save["completed_levels"] = completed
		save_current()

func is_level_completed(level_id: int) -> bool:
	if current_save.is_empty():
		return false
	return current_save.get("completed_levels", []).has(level_id)

func completed_count() -> int:
	if current_save.is_empty():
		return 0
	return current_save.get("completed_levels", []).size()

func _path_for(display_name: String) -> String:
	return SAVE_DIR + display_name.validate_filename() + ".json"

func _read_save(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var text: String = file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if parsed is Dictionary:
		return parsed
	return {}
