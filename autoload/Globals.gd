extends Node

# Runtime god-level carry between levels within a spoke. By default each level
# resets god levels (reset_god_levels = true), so this stays at zero for the
# tutorial. A level that opts out of resetting seeds from here, letting a
# future multi-god spoke carry progress forward. Cleared on hub return.

var carried_god_levels: Dictionary = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0}

func reset_carried_levels() -> void:
	for key: int in carried_god_levels:
		carried_god_levels[key] = 0

func set_carried_level(rune_id: int, level: int) -> void:
	if carried_god_levels.has(rune_id):
		carried_god_levels[rune_id] = level
