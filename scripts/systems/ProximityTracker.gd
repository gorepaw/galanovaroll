extends Node

# Detects the ball lingering inside Trael (rune_id 3) proximity fields.
# Each Trael node emits a circular ground field of radius field_radius.
# Inside a field, intensity rises smoothly from 0 at the edge to 1 at the
# center. Overlapping fields stack (their contributions sum), so the center
# of a cluster is the strongest spot.
#
# Distance is measured on the XZ plane only — the field lies flat on the floor.

signal proximity_detected(intensity)

const TRAEL_RUNE_ID: int = 3

var _field_radius: float = 12.0
var _node_positions: Array[Vector2] = []

func setup(ball: RigidBody3D, field_radius: float) -> void:
	_field_radius = field_radius
	_gather_trael_nodes()
	ball.position_updated.connect(_on_position_updated)

func _gather_trael_nodes() -> void:
	for node: Node in get_tree().get_nodes_in_group("rune_node"):
		var rune_id: Variant = node.get("rune_id")
		if rune_id == TRAEL_RUNE_ID and node is Node3D:
			var p: Vector3 = (node as Node3D).global_position
			_node_positions.append(Vector2(p.x, p.z))

func _on_position_updated(pos: Vector3, _delta: float) -> void:
	if _node_positions.is_empty() or _field_radius <= 0.0:
		return
	var ball_xz: Vector2 = Vector2(pos.x, pos.z)
	var intensity: float = 0.0
	for np: Vector2 in _node_positions:
		var d: float = ball_xz.distance_to(np)
		intensity += smoothstep(_field_radius, 0.0, d)
	if intensity > 0.0:
		emit_signal("proximity_detected", intensity)
