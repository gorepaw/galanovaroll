extends "res://scripts/effects/RuneEffectBase.gd"

# Ceta'Canaashen — Alignment / Precision
# Level 1-2:  burst impulse forward in current heading (force 18)
# Level 3-5:  impulse + alignment energy gain rate doubled for 3s
# Level 6-9:  stronger impulse (force 36) + alignment threshold lowered to 0.6 for 3s
# Level 10+:  full dash (force 60) + 2s window of no Ceta energy decay

const IMPULSE_BASE: float = 18.0
const IMPULSE_STRONG: float = 36.0
const IMPULSE_DASH: float = 60.0
const BOOST_DURATION: float = 3.0
const DASH_DURATION: float = 2.0
const LOWERED_THRESHOLD: float = 0.6

var _rune_system: Node = null
var _alignment_tracker: Node = null
var _decay_suppressed: bool = false

func get_rune_id() -> int:
	return 1

func setup_ceta(ball: RigidBody3D, energy_system: Node, rune_system: Node, alignment_tracker: Node) -> void:
	_rune_system = rune_system
	_alignment_tracker = alignment_tracker
	setup(ball, energy_system)

func _on_burst(level: int) -> void:
	var heading: Vector3 = _ball.linear_velocity.normalized()
	if heading == Vector3.ZERO:
		heading = -_ball.global_transform.basis.z

	if level <= 2:
		_ball.apply_central_impulse(heading * IMPULSE_BASE)

	elif level <= 5:
		_ball.apply_central_impulse(heading * IMPULSE_BASE)
		_boost_rate(2.0, BOOST_DURATION)

	elif level <= 9:
		_ball.apply_central_impulse(heading * IMPULSE_STRONG)
		_boost_rate(2.0, BOOST_DURATION)
		_lower_threshold(LOWERED_THRESHOLD, BOOST_DURATION)

	else:
		_ball.apply_central_impulse(heading * IMPULSE_DASH)
		_boost_rate(2.0, DASH_DURATION)
		_lower_threshold(LOWERED_THRESHOLD, DASH_DURATION)
		_suppress_decay(DASH_DURATION)

func _on_level_up(_level: int) -> void:
	pass

func _boost_rate(multiplier: float, duration: float) -> void:
	if _rune_system == null:
		return
	_rune_system.alignment_rate_multiplier = multiplier
	var timer: SceneTreeTimer = get_tree().create_timer(duration)
	timer.timeout.connect(func() -> void: _rune_system.alignment_rate_multiplier = 1.0)

func _lower_threshold(value: float, duration: float) -> void:
	if _alignment_tracker == null:
		return
	_alignment_tracker.threshold_override = value
	var timer: SceneTreeTimer = get_tree().create_timer(duration)
	timer.timeout.connect(func() -> void: _alignment_tracker.threshold_override = -1.0)

func _suppress_decay(duration: float) -> void:
	if _energy_system == null:
		return
	_decay_suppressed = true
	_energy_system.set_decay_suppressed(1, true)
	var timer: SceneTreeTimer = get_tree().create_timer(duration)
	timer.timeout.connect(func() -> void:
		_decay_suppressed = false
		_energy_system.set_decay_suppressed(1, false)
	)
