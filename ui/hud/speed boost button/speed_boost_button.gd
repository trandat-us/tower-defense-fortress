extends Button
class_name SpeedBoostButton

func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		text = "x2"
	else:
		text = "x1"
	LevelEvents.speed_boost_toggled.emit(2 if toggled_on else 1)
