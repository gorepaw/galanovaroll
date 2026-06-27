extends "res://scripts/effects/RuneEffectBase.gd"

# Alaaga — Force / Raw Impact
# Each Alaaga level increases the bonus impulse the ball imparts to dynamic
# bodies on collision, so heavy objects get knocked around harder as you rank
# up. At level 0 the bonus is 0 (pure physics).

const IMPACT_BONUS_PER_LEVEL: float = 1.0

func get_rune_id() -> int:
	return 6

func _on_burst(_level: int) -> void:
	pass

func _on_level_up(level: int) -> void:
	_ball.set_impact_bonus(level * IMPACT_BONUS_PER_LEVEL)
