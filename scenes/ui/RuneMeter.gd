extends Control

var _rune_color: Color = Color.WHITE

func setup(rune_name: String, color: Color) -> void:
	_rune_color = color
	$VBoxContainer/Label.text = rune_name
	$VBoxContainer/ProgressBar.modulate = color

func set_value(value: float) -> void:
	$VBoxContainer/ProgressBar.value = value

func set_level(level: int) -> void:
	$VBoxContainer/LevelLabel.text = "Lv. " + str(level)

func flash() -> void:
	var tween: Tween = create_tween()
	tween.tween_property($VBoxContainer/ProgressBar, "modulate", Color.WHITE, 0.05)
	tween.tween_property($VBoxContainer/ProgressBar, "modulate", _rune_color, 0.4)
