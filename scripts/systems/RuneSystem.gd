extends Node

const ALIGNMENT_ENERGY_RATE: float = 0.3
const RUNE_NODE_HIT_ENERGY: float = 20.0
const LIQUIMETAL_CHAIN_BASE: float = 8.0
const LIQUIMETAL_RUNE_ID: int = 2
const TRAEL_RUNE_ID: int = 3
const PROXIMITY_ENERGY_RATE: float = 0.3
const BUKAGA_RUNE_ID: int = 4
const LOOP_BASE_GAIN: float = 5.0
const LOOP_RADIUS_FACTOR: float = 1.0
const OBJECT_ENCLOSE_BONUS: float = 15.0
const NODE_ENCLOSE_BONUS: float = 20.0
const CAELITH_RUNE_ID: int = 5
const ASCENSION_ENERGY_RATE: float = 1.0
const ALAAGA_RUNE_ID: int = 6

var alignment_rate_multiplier: float = 1.0

var _energy_system: Node = null

func setup(path_tracker: Node, alignment_tracker: Node, energy_system: Node, chain_tracker: Node, proximity_tracker: Node, ascension_tracker: Node) -> void:
	_energy_system = energy_system
	path_tracker.loop_detected.connect(_on_loop_detected)
	alignment_tracker.alignment_detected.connect(_on_alignment_detected)
	chain_tracker.chain_extended.connect(_on_chain_extended)
	proximity_tracker.proximity_detected.connect(_on_proximity_detected)
	ascension_tracker.ascension_detected.connect(_on_ascension_detected)

func receive_collision(target: Node, object_type: String, _impact_force: float) -> void:
	if _energy_system == null:
		return
	if object_type == "rune_node":
		var rune_id: Variant = target.get("rune_id")
		# Liquimetal (chain), Trael (proximity), Bukaga (enclosure) and Alaaga
		# (impact-scaled) all earn through other means, never flat per-hit energy.
		if rune_id != null and rune_id != LIQUIMETAL_RUNE_ID and rune_id != TRAEL_RUNE_ID and rune_id != BUKAGA_RUNE_ID and rune_id != ALAAGA_RUNE_ID:
			_energy_system.add_energy(rune_id, RUNE_NODE_HIT_ENERGY)

func _on_chain_extended(chain_length: int, _node: Node) -> void:
	if _energy_system == null:
		return
	_energy_system.add_energy(LIQUIMETAL_RUNE_ID, LIQUIMETAL_CHAIN_BASE * chain_length)

func _on_proximity_detected(intensity: float) -> void:
	if _energy_system == null:
		return
	_energy_system.add_energy(TRAEL_RUNE_ID, PROXIMITY_ENERGY_RATE * intensity)

func _on_ascension_detected(intensity: float) -> void:
	if _energy_system == null:
		return
	_energy_system.add_energy(CAELITH_RUNE_ID, ASCENSION_ENERGY_RATE * intensity)

func _on_loop_detected(center: Vector3, radius: float, quality: float) -> void:
	if _energy_system == null:
		return
	# Larger loops pay more; enclosing objects pays a bonus, and enclosing
	# rune nodes pays an even bigger one.
	var energy: float = quality * (LOOP_BASE_GAIN + radius * LOOP_RADIUS_FACTOR)
	energy += _count_enclosed(center, radius, "orbitable") * OBJECT_ENCLOSE_BONUS
	energy += _count_enclosed(center, radius, "rune_node") * NODE_ENCLOSE_BONUS
	_energy_system.add_energy(BUKAGA_RUNE_ID, energy)

func _count_enclosed(center: Vector3, radius: float, group: String) -> int:
	var c: Vector2 = Vector2(center.x, center.z)
	var count: int = 0
	for node: Node in get_tree().get_nodes_in_group(group):
		if node is Node3D:
			var p: Vector3 = (node as Node3D).global_position
			if c.distance_to(Vector2(p.x, p.z)) < radius:
				count += 1
	return count

func _on_alignment_detected(_direction: Vector3, quality: float) -> void:
	if _energy_system == null:
		return
	_energy_system.add_energy(1, ALIGNMENT_ENERGY_RATE * alignment_rate_multiplier * quality)
