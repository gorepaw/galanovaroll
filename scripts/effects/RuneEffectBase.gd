extends Node

var _ball: RigidBody3D = null
var _energy_system: Node = null
var _current_level: int = 0

func get_rune_id() -> int:
	return 0

func setup(ball: RigidBody3D, energy_system: Node) -> void:
	_ball = ball
	_energy_system = energy_system
	energy_system.rune_burst_triggered.connect(_on_burst_triggered)
	energy_system.rune_level_changed.connect(_on_rune_level_changed)

func _on_burst_triggered(rune_id: int) -> void:
	if rune_id != get_rune_id():
		return
	_on_burst(_current_level)

func _on_rune_level_changed(rune_id: int, new_level: int) -> void:
	if rune_id != get_rune_id():
		return
	_current_level = new_level
	_on_level_up(new_level)

func _on_burst(_level: int) -> void:
	pass

func _on_level_up(_level: int) -> void:
	pass
