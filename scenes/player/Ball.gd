extends RigidBody3D

signal collided_with(target, impact_force)
signal position_updated(global_position, delta)

@export var impact_sound: AudioStream = null
@export var burst_sound: AudioStream = null

var _input_force: Vector3 = Vector3.ZERO
var _burst_player: AudioStreamPlayer3D = null
var _impact_bonus: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_setup_particles()
	$AudioStreamPlayer3D.stream = impact_sound
	_burst_player = AudioStreamPlayer3D.new()
	_burst_player.stream = burst_sound
	add_child(_burst_player)

func _physics_process(delta: float) -> void:
	if _input_force != Vector3.ZERO:
		apply_central_force(_input_force)
	emit_signal("position_updated", global_position, delta)

func receive_force(force: Vector3) -> void:
	_input_force = force

func apply_jump(force: float) -> void:
	apply_central_impulse(Vector3.UP * force)

func set_impact_bonus(value: float) -> void:
	_impact_bonus = value

func trigger_burst_effect(color: Color) -> void:
	var particles: GPUParticles3D = $GPUParticles3D
	var mat := particles.process_material as ParticleProcessMaterial
	if mat:
		mat.color = color
	particles.restart()
	if burst_sound:
		_burst_player.play()

func _on_body_entered(body: Node) -> void:
	var impact: float = linear_velocity.length() * mass
	emit_signal("collided_with", body, impact)
	# Alaaga's force modifier: shove dynamic bodies harder as its level grows.
	if _impact_bonus > 0.0 and body is RigidBody3D:
		var direction: Vector3 = linear_velocity.normalized()
		(body as RigidBody3D).apply_central_impulse(direction * impact * _impact_bonus)
	if impact_sound and impact > 2.0:
		$AudioStreamPlayer3D.volume_db = clamp(linear_to_db(impact / 20.0), -24.0, 0.0)
		$AudioStreamPlayer3D.play()

func _setup_particles() -> void:
	var particles: GPUParticles3D = $GPUParticles3D
	particles.amount = 48
	particles.lifetime = 0.8
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.emitting = false

	var process_mat := ParticleProcessMaterial.new()
	process_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process_mat.emission_sphere_radius = 0.6
	process_mat.spread = 180.0
	process_mat.initial_velocity_min = 4.0
	process_mat.initial_velocity_max = 10.0
	process_mat.gravity = Vector3(0.0, -4.0, 0.0)
	process_mat.scale_min = 0.1
	process_mat.scale_max = 0.25
	process_mat.color = Color.WHITE
	particles.process_material = process_mat

	var draw_mesh := SphereMesh.new()
	draw_mesh.radius = 0.12
	draw_mesh.height = 0.24
	var mesh_mat := StandardMaterial3D.new()
	mesh_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh_mat.vertex_color_use_as_albedo = true
	mesh_mat.emission_enabled = true
	mesh_mat.emission_energy_multiplier = 3.0
	draw_mesh.material = mesh_mat
	particles.draw_passes = 1
	particles.draw_pass_1 = draw_mesh
