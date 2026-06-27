extends Node

signal rune_energy_changed(rune_id, new_value)
signal rune_burst_triggered(rune_id)
signal rune_level_changed(rune_id, new_level)

const MAX_ENERGY: float = 100.0
const DECAY_RATE: float = 5.0
const BURST_THRESHOLD: float = 100.0
const COLLISION_FORCE_SCALE: float = 0.5
const NODE_FORCE_SCALE: float = 1.0
const IMPACT_THRESHOLD: float = 6.0

var _energy: Dictionary = {
	1: 0.0,
	2: 0.0,
	3: 0.0,
	4: 0.0,
	5: 0.0,
	6: 0.0
}

var _levels: Dictionary = {
	1: 0,
	2: 0,
	3: 0,
	4: 0,
	5: 0,
	6: 0
}

var _decay_suppressed: Dictionary = {
	1: false,
	2: false,
	3: false,
	4: false,
	5: false,
	6: false
}

var _enabled: Dictionary = {
	1: true,
	2: true,
	3: true,
	4: true,
	5: true,
	6: true
}

func get_level(rune_id: int) -> int:
	return _levels.get(rune_id, 0)

func set_levels(levels: Dictionary) -> void:
	for id: int in _levels:
		if levels.has(id):
			_levels[id] = int(levels[id])

func set_decay_suppressed(rune_id: int, suppressed: bool) -> void:
	_decay_suppressed[rune_id] = suppressed

func set_enabled_runes(rune_ids: Array) -> void:
	for key: int in _enabled:
		_enabled[key] = false
	for id: int in rune_ids:
		if _enabled.has(id):
			_enabled[id] = true

func is_rune_enabled(rune_id: int) -> bool:
	return _enabled.get(rune_id, false)

func _process(delta: float) -> void:
	for rune_id: int in _energy:
		if _energy[rune_id] > 0.0 and not _decay_suppressed[rune_id]:
			_set_energy(rune_id, _energy[rune_id] - DECAY_RATE * delta)

func add_energy(rune_id: int, amount: float) -> void:
	if not _energy.has(rune_id):
		return
	if not _enabled[rune_id]:
		return
	_set_energy(rune_id, _energy[rune_id] + amount)

func receive_collision(object_type: String, impact_force: float) -> void:
	# Alaaga (force) only rewards real slams — gentle bumps are ignored, and
	# rune nodes pay more than incidental geometry.
	if impact_force < IMPACT_THRESHOLD:
		return
	var scale: float = NODE_FORCE_SCALE if object_type == "rune_node" else COLLISION_FORCE_SCALE
	add_energy(6, impact_force * scale)

func get_energy(rune_id: int) -> float:
	return _energy.get(rune_id, 0.0)

func _set_energy(rune_id: int, value: float) -> void:
	var clamped: float = clamp(value, 0.0, MAX_ENERGY)
	_energy[rune_id] = clamped
	emit_signal("rune_energy_changed", rune_id, clamped)
	if clamped >= BURST_THRESHOLD:
		_trigger_burst(rune_id)

func _trigger_burst(rune_id: int) -> void:
	_levels[rune_id] += 1
	emit_signal("rune_burst_triggered", rune_id)
	emit_signal("rune_level_changed", rune_id, _levels[rune_id])
	_energy[rune_id] = 0.0
	emit_signal("rune_energy_changed", rune_id, 0.0)
