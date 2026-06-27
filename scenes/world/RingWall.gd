extends Node3D

# Builds a circular containment wall from box segments arranged in a ring.
# Parametric so the same script serves any round arena.

@export var radius: float = 40.0
@export var segments: int = 24
@export var wall_height: float = 3.0
@export var wall_thickness: float = 0.5

func _ready() -> void:
	var seg_angle: float = TAU / float(segments)
	# Chord length between adjacent segment centers, plus a little overlap.
	var seg_length: float = 2.0 * radius * sin(seg_angle / 2.0) + 0.5
	for i: int in range(segments):
		var angle: float = seg_angle * float(i)
		_build_segment(angle, seg_length)

func _build_segment(angle: float, seg_length: float) -> void:
	var seg := StaticBody3D.new()
	seg.add_to_group("wall")
	seg.position = Vector3(radius * cos(angle), wall_height / 2.0, radius * sin(angle))
	seg.rotation = Vector3(0.0, -angle, 0.0)

	var box_size: Vector3 = Vector3(wall_thickness, wall_height, seg_length)

	var shape := BoxShape3D.new()
	shape.size = box_size
	var col := CollisionShape3D.new()
	col.shape = shape
	seg.add_child(col)

	var mesh := BoxMesh.new()
	mesh.size = box_size
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	seg.add_child(mi)

	add_child(seg)
