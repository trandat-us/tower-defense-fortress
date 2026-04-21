extends MeshInstance3D
class_name DroppedGoldsSprite

@onready var golds_label: Label = %GoldsLabel

var golds: int = 1
var start_position: Vector3

func _ready() -> void:
	golds_label.text = "+ %d" % golds
	global_position = start_position
	transparency = 1
	
	var camera := get_viewport().get_camera_3d()
	var camera_up := camera.global_transform.basis.y
	var peak_pos := global_position + camera_up * 1.0
	
	var tween = create_tween()
	tween.tween_property(self, "global_position", peak_pos, 0.6) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.parallel().tween_property(self, "transparency", 0, 0.4)
	
	tween.tween_interval(1.0)
	tween.tween_property(self, "transparency", 1, 0.3)
	tween.tween_callback(queue_free)
