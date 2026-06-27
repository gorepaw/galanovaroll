extends Node

const FORCE_MAGNITUDE: float = 20.0

var _ball: RigidBody3D = null
var _get_cam_azimuth: Callable
var _get_jump_force: Callable

func setup(ball: RigidBody3D, get_cam_azimuth: Callable, get_jump_force: Callable) -> void:
	_ball = ball
	_get_cam_azimuth = get_cam_azimuth
	_get_jump_force = get_jump_force

func _physics_process(_delta: float) -> void:
	if _ball == null:
		return

	if Input.is_action_just_pressed("jump") and _get_jump_force.is_valid():
		_ball.apply_jump(_get_jump_force.call())

	var direction := Vector3.ZERO

	if Input.is_action_pressed("move_forward"):
		direction.z -= 1.0
	if Input.is_action_pressed("move_back"):
		direction.z += 1.0
	if Input.is_action_pressed("move_left"):
		direction.x -= 1.0
	if Input.is_action_pressed("move_right"):
		direction.x += 1.0

	if direction != Vector3.ZERO:
		direction = direction.normalized()
		var azimuth: float = _get_cam_azimuth.call()
		var cam_forward: Vector3 = Vector3(-sin(azimuth), 0.0, -cos(azimuth))
		var cam_right: Vector3 = Vector3(cos(azimuth), 0.0, -sin(azimuth))
		direction = (cam_right * direction.x) + (cam_forward * -direction.z)

	_ball.receive_force(direction * FORCE_MAGNITUDE)
