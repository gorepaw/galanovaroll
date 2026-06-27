extends CanvasLayer

const RuneDataScript = preload("res://scripts/data/RuneData.gd")
const AudiowideFont = preload("res://assets/fonts/Audiowide/Audiowide-Regular.ttf")

var _meters: Array[Control] = []

func setup(energy_system: Node, enabled_runes: Array) -> void:
	var theme := Theme.new()
	theme.default_font = AudiowideFont
	$Control.theme = theme

	var rune_data: Resource = RuneDataScript.new()
	_meters = [
		$Control/HBoxContainer/MeterCeta,
		$Control/HBoxContainer/MeterLiquimetal,
		$Control/HBoxContainer/MeterTrael,
		$Control/HBoxContainer/MeterBukaga,
		$Control/HBoxContainer/MeterCaelith,
		$Control/HBoxContainer/MeterAlaaga,
	]
	for i: int in range(6):
		var rune: Dictionary = rune_data.runes[i + 1]
		_meters[i].setup(rune["shortname"], rune["color"])
		_meters[i].visible = enabled_runes.has(i + 1)
	energy_system.rune_energy_changed.connect(_on_rune_energy_changed)
	energy_system.rune_burst_triggered.connect(_on_rune_burst)
	energy_system.rune_level_changed.connect(_on_rune_level_changed)

func _on_rune_energy_changed(rune_id: int, new_value: float) -> void:
	_meters[rune_id - 1].set_value(new_value)

func _on_rune_burst(rune_id: int) -> void:
	_meters[rune_id - 1].flash()

func _on_rune_level_changed(rune_id: int, new_level: int) -> void:
	_meters[rune_id - 1].set_level(new_level)
