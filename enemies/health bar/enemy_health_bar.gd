extends ProgressBar
class_name EnemyHealthBar

var color_ramp: GradientTexture1D = preload("uid://kwmuc2i4nwli")

func init_bar(info: EnemyInfo) -> void:
	max_value = info.max_health
	value = info.max_health
	
	info.health_changed.connect(_on_health_changed)

func _on_health_changed(health: int) -> void:
	value = health
	var fill_style = get_theme_stylebox("fill") as StyleBoxFlat
	fill_style.bg_color = color_ramp.gradient.sample(value / max_value)
