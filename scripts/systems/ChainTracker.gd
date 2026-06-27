extends Node

# Tracks "connection chains" — sequences of distinct rune nodes hit in a row.
# A chain extends when the ball hits a participating node NOT already in the
# current chain. Hitting a node already in the chain breaks it (no score),
# regardless of how much time has passed.
#
# Modularity: participating_rune_ids controls which node types can join a chain.
# Default is Liquimetal (2) only. Per level, add other rune_ids and subscribe
# new consumers to chain_extended to build connection effects between
# Liquimetal nodes and other node types.
#
# A chain also goes stale and resets if no new node is hit within
# stale_timeout seconds. Set stale_timeout <= 0 to disable the timeout.

signal chain_extended(chain_length, node)
signal chain_broken(broken_length)

var participating_rune_ids: Array[int] = [2]
var stale_timeout: float = 5.0

var _chain: Array[int] = []
var _time_since_last_hit: float = 0.0

func _process(delta: float) -> void:
	if _chain.is_empty() or stale_timeout <= 0.0:
		return
	_time_since_last_hit += delta
	if _time_since_last_hit >= stale_timeout:
		_break_chain()

func register_node_hit(node: Node) -> void:
	var rune_id: Variant = node.get("rune_id")
	if rune_id == null:
		return
	if not participating_rune_ids.has(rune_id):
		return

	var id: int = node.get_instance_id()
	if _chain.has(id):
		_break_chain()
		return

	_chain.append(id)
	_time_since_last_hit = 0.0
	emit_signal("chain_extended", _chain.size(), node)

func get_chain_length() -> int:
	return _chain.size()

func reset() -> void:
	_chain.clear()
	_time_since_last_hit = 0.0

func _break_chain() -> void:
	var broken_length: int = _chain.size()
	_chain.clear()
	_time_since_last_hit = 0.0
	emit_signal("chain_broken", broken_length)
