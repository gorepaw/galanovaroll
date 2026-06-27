extends Node

var _energy_system: Node = null
var _rune_system: Node = null
var _chain_tracker: Node = null

func setup(ball: RigidBody3D, energy_system: Node, rune_system: Node, chain_tracker: Node) -> void:
	_energy_system = energy_system
	_rune_system = rune_system
	_chain_tracker = chain_tracker
	ball.collided_with.connect(_on_ball_collided)

func _on_ball_collided(target: Node, impact_force: float) -> void:
	var object_type: String = _classify(target)
	if _energy_system:
		_energy_system.receive_collision(object_type, impact_force)
	if _rune_system:
		_rune_system.receive_collision(target, object_type, impact_force)
	if _chain_tracker and object_type == "rune_node":
		_chain_tracker.register_node_hit(target)

func _classify(body: Node) -> String:
	if body.is_in_group("rune_node"):
		return "rune_node"
	if body.is_in_group("bumper"):
		return "bumper"
	if body.is_in_group("wall"):
		return "wall"
	return "unknown"
