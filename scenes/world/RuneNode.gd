extends StaticBody3D

const RuneDataScript = preload("res://scripts/data/RuneData.gd")

@export var rune_id: int = 0

func _ready() -> void:
	if rune_id == 0:
		return
	var rune_data: Resource = RuneDataScript.new()
	if not rune_data.runes.has(rune_id):
		return
	var color: Color = rune_data.runes[rune_id]["color"]
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 0.5
	$MeshInstance3D.material_override = mat
