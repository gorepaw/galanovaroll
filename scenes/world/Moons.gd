extends Node3D

# Slowly spins this rig so its child meshes orbit overhead like moons.
# Purely decorative — the moons have no collision and are not counted by
# any rune system.

@export var spin_speed: float = 0.4

func _process(delta: float) -> void:
	rotate_y(spin_speed * delta)
