extends Node3D

@onready var camera_pivot: Node3D = $CameraPivot

func _ready() -> void:
	var tween = create_tween().set_loops()
	tween.tween_property(camera_pivot, "rotation_degrees:y", 3, 15) \
		.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(camera_pivot, "rotation_degrees:y", -3, 15) \
		.set_ease(Tween.EASE_IN_OUT)
