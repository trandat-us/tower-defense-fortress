extends TextureRect
class_name TrophySilhouette

signal animation_finished

@onready var trophy_icon: TextureRect = $TrophyIcon

@export_range(0.001, 1, 0.001, "or_greater", "suffix:s") var animation_duration: float = 0.4

func _ready() -> void:
	trophy_icon.pivot_offset = trophy_icon.size / 2

func _reset() -> void:
	trophy_icon.scale = Vector2.ONE * 1.5
	trophy_icon.modulate.a = 0.0

func display(animation: bool = true) -> void:
	if animation:
		_reset()
		var tween = create_tween()
		tween.tween_property(trophy_icon, "modulate:a", 1.0, animation_duration)
		tween.parallel().tween_property(trophy_icon, "scale", Vector2.ONE, animation_duration) \
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
		tween.tween_callback(func(): animation_finished.emit())
	else:
		trophy_icon.scale = Vector2.ONE
		trophy_icon.modulate.a = 1
