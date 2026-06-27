extends Node3D

const CAM_DISTANCE: float = 15.0
const CAM_ROTATE_SPEED: float = 2.0
const CAM_SMOOTH: float = 10.0
const MOUSE_SENSITIVITY: float = 0.003
const JUMP_BASE: float = 0.3
const JUMP_PER_LEVEL: float = 2.5
const RuneDataScript = preload("res://scripts/data/RuneData.gd")
const ChainTrackerScript = preload("res://scripts/systems/ChainTracker.gd")
const ProximityTrackerScript = preload("res://scripts/systems/ProximityTracker.gd")
const AscensionTrackerScript = preload("res://scripts/systems/AscensionTracker.gd")
const CetaEffectScript = preload("res://scripts/effects/CetaEffect.gd")
const LiquimetalEffectScript = preload("res://scripts/effects/LiquimetalEffect.gd")
const TraelEffectScript = preload("res://scripts/effects/TraelEffect.gd")
const BukagaEffectScript = preload("res://scripts/effects/BukagaEffect.gd")
const CaelithEffectScript = preload("res://scripts/effects/CaelithEffect.gd")
const AlaagaEffectScript = preload("res://scripts/effects/AlaagaEffect.gd")

@export var ambience: AudioStream = null
@export var chain_stale_timeout: float = 5.0
@export var trael_field_radius: float = 12.0
@export var loop_close_threshold: float = 4.0
@export var enabled_runes: Array[int] = [1, 2, 3, 4, 5, 6]
@export var level_id: int = 0
@export var reset_god_levels: bool = true
@export var is_hub: bool = false

var _ball: RigidBody3D = null
var _cam_azimuth: float = 0.0
var _cam_elevation: float = 0.8
var _rune_data: Resource = null
var _ambience_player: AudioStreamPlayer = null

func _ready() -> void:
	_ball = $Ball
	_rune_data = RuneDataScript.new()
	var input_system: Node = $Systems/InputSystem
	var collision_system: Node = $Systems/CollisionSystem
	var energy_system: Node = $Systems/EnergySystem
	var rune_system: Node = $Systems/RuneSystem
	var path_tracker: Node = $Systems/PathTracker
	var alignment_tracker: Node = $Systems/AlignmentTracker

	var chain_tracker: Node = ChainTrackerScript.new()
	chain_tracker.stale_timeout = chain_stale_timeout
	$Systems.add_child(chain_tracker)

	var proximity_tracker: Node = ProximityTrackerScript.new()
	$Systems.add_child(proximity_tracker)

	var ascension_tracker: Node = AscensionTrackerScript.new()
	$Systems.add_child(ascension_tracker)

	energy_system.set_enabled_runes(enabled_runes)
	if is_hub:
		Globals.reset_carried_levels()
	if not reset_god_levels:
		energy_system.set_levels(Globals.carried_god_levels)
	energy_system.rune_level_changed.connect(_on_level_changed_carry)

	input_system.setup(
		_ball,
		func() -> float: return _cam_azimuth,
		func() -> float: return JUMP_BASE + energy_system.get_level(5) * JUMP_PER_LEVEL
	)
	collision_system.setup(_ball, energy_system, rune_system, chain_tracker)
	path_tracker.loop_close_threshold = loop_close_threshold
	path_tracker.setup(_ball)
	alignment_tracker.setup(_ball)
	proximity_tracker.setup(_ball, trael_field_radius)
	ascension_tracker.setup(_ball)
	rune_system.setup(path_tracker, alignment_tracker, energy_system, chain_tracker, proximity_tracker, ascension_tracker)
	$HUD.setup(energy_system, enabled_runes)

	for portal: Node in get_tree().get_nodes_in_group("portal"):
		portal.setup(energy_system)
		portal.entered_active.connect(_on_portal_entered)

	energy_system.rune_burst_triggered.connect(_on_rune_burst)

	_setup_rune_effects(energy_system, rune_system, alignment_tracker)

	_ambience_player = AudioStreamPlayer.new()
	_ambience_player.stream = ambience
	_ambience_player.volume_db = -12.0
	add_child(_ambience_player)
	if ambience:
		_ambience_player.play()

	$DirectionalLight3D.rotation_degrees = Vector3(-45, 0, 0)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_cam_azimuth -= event.relative.x * MOUSE_SENSITIVITY
		_cam_elevation = clamp(_cam_elevation + event.relative.y * MOUSE_SENSITIVITY, 0.2, 1.4)
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event is InputEventMouseButton and event.pressed and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta: float) -> void:
	_update_camera(delta)

func _update_camera(delta: float) -> void:
	if Input.is_action_pressed("camera_left"):
		_cam_azimuth -= CAM_ROTATE_SPEED * delta
	if Input.is_action_pressed("camera_right"):
		_cam_azimuth += CAM_ROTATE_SPEED * delta
	if Input.is_action_pressed("camera_up"):
		_cam_elevation = clamp(_cam_elevation + CAM_ROTATE_SPEED * delta, 0.2, 1.4)
	if Input.is_action_pressed("camera_down"):
		_cam_elevation = clamp(_cam_elevation - CAM_ROTATE_SPEED * delta, 0.2, 1.4)

	var ball_pos: Vector3 = _ball.global_position
	var offset: Vector3 = Vector3(
		sin(_cam_azimuth) * cos(_cam_elevation),
		sin(_cam_elevation),
		cos(_cam_azimuth) * cos(_cam_elevation)
	) * CAM_DISTANCE

	var target: Vector3 = ball_pos + offset
	$Camera3D.global_position = $Camera3D.global_position.lerp(target, CAM_SMOOTH * delta)
	$Camera3D.look_at(ball_pos)

func _setup_rune_effects(energy_system: Node, rune_system: Node, alignment_tracker: Node) -> void:
	var ceta: Node = CetaEffectScript.new()
	$Systems.add_child(ceta)
	ceta.setup_ceta(_ball, energy_system, rune_system, alignment_tracker)

	var liquimetal: Node = LiquimetalEffectScript.new()
	$Systems.add_child(liquimetal)
	liquimetal.setup(_ball, energy_system)

	var trael: Node = TraelEffectScript.new()
	$Systems.add_child(trael)
	trael.setup(_ball, energy_system)

	var bukaga: Node = BukagaEffectScript.new()
	$Systems.add_child(bukaga)
	bukaga.setup(_ball, energy_system)

	var caelith: Node = CaelithEffectScript.new()
	$Systems.add_child(caelith)
	caelith.setup(_ball, energy_system)

	var alaaga: Node = AlaagaEffectScript.new()
	$Systems.add_child(alaaga)
	alaaga.setup(_ball, energy_system)

func _on_rune_burst(rune_id: int) -> void:
	var color: Color = _rune_data.runes[rune_id]["color"]
	_ball.trigger_burst_effect(color)

func _on_level_changed_carry(rune_id: int, new_level: int) -> void:
	Globals.set_carried_level(rune_id, new_level)

func _on_portal_entered(target_scene: String) -> void:
	if level_id > 0:
		SaveSystem.mark_level_completed(level_id)
	if target_scene != "":
		get_tree().change_scene_to_file(target_scene)
