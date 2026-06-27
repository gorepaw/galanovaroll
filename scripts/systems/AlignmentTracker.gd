extends Node

signal alignment_detected(direction, quality)

const SAMPLE_COUNT: int = 20
const ALIGNMENT_THRESHOLD: float = 0.85
const MIN_DISPLACEMENT: float = 0.01

var threshold_override: float = -1.0

var _last_position: Vector3 = Vector3.ZERO
var _directions: Array[Vector3] = []
var _has_last_position: bool = false

func setup(ball: RigidBody3D) -> void:
	ball.position_updated.connect(_on_position_updated)

func _on_position_updated(pos: Vector3, _delta: float) -> void:
	if not _has_last_position:
		_last_position = pos
		_has_last_position = true
		return

	var displacement: Vector3 = pos - _last_position
	_last_position = pos

	if displacement.length() < MIN_DISPLACEMENT:
		return

	_directions.append(displacement.normalized())
	if _directions.size() > SAMPLE_COUNT:
		_directions.pop_front()

	if _directions.size() < SAMPLE_COUNT:
		return

	_check_alignment()

func _check_alignment() -> void:
	var dominant := _calculate_dominant_direction()
	if dominant == Vector3.ZERO:
		return
	var quality := _calculate_quality(dominant)
	var threshold: float = threshold_override if threshold_override >= 0.0 else ALIGNMENT_THRESHOLD
	if quality >= threshold:
		emit_signal("alignment_detected", dominant, quality)

func _calculate_dominant_direction() -> Vector3:
	var sum := Vector3.ZERO
	for dir: Vector3 in _directions:
		sum += dir
	if sum.length() < 0.001:
		return Vector3.ZERO
	return sum.normalized()

func _calculate_quality(dominant: Vector3) -> float:
	var total := 0.0
	for dir: Vector3 in _directions:
		total += dir.dot(dominant)
	return clamp(total / _directions.size(), 0.0, 1.0)
