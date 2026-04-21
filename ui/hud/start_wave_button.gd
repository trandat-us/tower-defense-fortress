extends Button

const LERP_SPEED = 16.0

func _ready() -> void:
	pivot_offset = size / 2

func _process(delta: float) -> void:
	if is_hovered():
		scale = lerp(scale, Vector2.ONE * 1.05, delta * LERP_SPEED)
	else:
		scale = lerp(scale, Vector2.ONE, delta * LERP_SPEED)
