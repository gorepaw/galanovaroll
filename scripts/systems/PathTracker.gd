extends Node

signal loop_detected(center, radius, quality)

const BUFFER_SIZE: int = 600
const MIN_LOOP_SAMPLES: int = 30

# How close the ball must return to an earlier point to count as closing a
# loop. Wider = easier (and looser) loops, but the closure scan runs every
# frame, so very wide values in dense arenas cost more. Tunable per level.
var loop_close_threshold: float = 4.0

var _positions: Array[Vector3] = []

func setup(ball: RigidBody3D) -> void:
	ball.position_updated.connect(_on_position_updated)

func _on_position_updated(pos: Vector3, _delta: float) -> void:
	_positions.append(pos)
	if _positions.size() > BUFFER_SIZE:
		_positions.pop_front()
	_check_for_loop()

func _check_for_loop() -> void:
	var count := _positions.size()
	if count < MIN_LOOP_SAMPLES:
		return

	var current: Vector3 = _positions[count - 1]

	for i in range(count - MIN_LOOP_SAMPLES - 1, -1, -1):
		if current.distance_to(_positions[i]) < loop_close_threshold:
			var loop_slice: Array = _positions.slice(i, count)
			var center := _calculate_center(loop_slice)
			var radius := _calculate_radius(loop_slice, center)
			var quality := _calculate_quality(loop_slice, center, radius)
			emit_signal("loop_detected", center, radius, quality)
			_positions.clear()
			return

func _calculate_center(positions: Array) -> Vector3:
	var sum := Vector3.ZERO
	for pos: Vector3 in positions:
		sum += pos
	return sum / positions.size()

func _calculate_radius(positions: Array, center: Vector3) -> float:
	var total := 0.0
	for pos: Vector3 in positions:
		total += pos.distance_to(center)
	return total / positions.size()

func _calculate_quality(positions: Array, center: Vector3, radius: float) -> float:
	if radius == 0.0:
		return 0.0
	var variance := 0.0
	for pos: Vector3 in positions:
		var diff: float = pos.distance_to(center) - radius
		variance += diff * diff
	variance /= positions.size()
	return clamp(1.0 - (variance / (radius * radius)), 0.0, 1.0)
