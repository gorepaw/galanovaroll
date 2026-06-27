extends Area3D

# A gateway the ball rolls through to change scenes. Two gating modes:
#   - required_rune_id > 0:  in-level gate. Opens when that god's live level
#     reaches required_level. Colored by that god (from RuneData).
#   - required_rune_id <= 0: hub gate. Opens when the save's completed-level
#     count reaches required_completions.
# Locked portals are passthrough — a dim colored marker with no effect.

const RuneDataScript = preload("res://scripts/data/RuneData.gd")

signal entered_active(target_scene)

@export var target_scene: String = ""
@export var required_rune_id: int = 0
@export var required_level: int = 5
@export var required_completions: int = 0

var _unlocked: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if required_rune_id <= 0:
		_set_unlocked(SaveSystem.completed_count() >= required_completions)
	else:
		_set_unlocked(false)

func setup(energy_system: Node) -> void:
	if required_rune_id <= 0:
		return
	energy_system.rune_level_changed.connect(_on_rune_level_changed)
	_set_unlocked(energy_system.get_level(required_rune_id) >= required_level)

func _on_rune_level_changed(rune_id: int, new_level: int) -> void:
	if rune_id == required_rune_id and new_level >= required_level:
		_set_unlocked(true)

func _on_body_entered(body: Node) -> void:
	if _unlocked and body.name == "Ball":
		emit_signal("entered_active", target_scene)

func _set_unlocked(value: bool) -> void:
	_unlocked = value
	var color: Color = _portal_color()
	var mat := StandardMaterial3D.new()
	if _unlocked:
		mat.albedo_color = color
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy_multiplier = 1.8
	else:
		mat.albedo_color = Color(color.r, color.g, color.b, 0.3)
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	$MeshInstance3D.material_override = mat

func _portal_color() -> Color:
	if required_rune_id > 0:
		var rune_data: Resource = RuneDataScript.new()
		if rune_data.runes.has(required_rune_id):
			return rune_data.runes[required_rune_id]["color"]
	return Color(0.9, 0.9, 0.9)
