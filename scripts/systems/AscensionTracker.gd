extends Node

# Detects the ball gaining the vertical axis — the source of Caelith energy.
# Three contributions stack each physics frame:
#   - altitude:  how far above the resting height the ball is
#   - upward velocity: how fast it is currently rising
#   - air time:  a flat amount while clearly off the ground
# The summed intensity is emitted; RuneSystem turns it into Caelith energy.

signal ascension_detected(intensity)

const BASELINE_HEIGHT: float = 0.5   # ball center height at rest on the floor
const AIR_THRESHOLD: float = 1.0     # height above which the ball counts as airborne
const ALTITUDE_WEIGHT: float = 0.04
const UPVEL_WEIGHT: float = 0.05
const AIRTIME_WEIGHT: float = 0.3

var _ball: RigidBody3D = null

func setup(ball: RigidBody3D) -> void:
	_ball = ball
	ball.position_updated.connect(_on_position_updated)

func _on_position_updated(pos: Vector3, _delta: float) -> void:
	if _ball == null:
		return
	var altitude: float = max(pos.y - BASELINE_HEIGHT, 0.0)
	var up_velocity: float = max(_ball.linear_velocity.y, 0.0)
	var airborne: float = 1.0 if altitude > AIR_THRESHOLD else 0.0
	var intensity: float = altitude * ALTITUDE_WEIGHT + up_velocity * UPVEL_WEIGHT + airborne * AIRTIME_WEIGHT
	if intensity > 0.0:
		emit_signal("ascension_detected", intensity)
