extends ProgressBar
class_name HealthBar

@onready var health_label: Label = $HealthLabel

var color_ramp: GradientTexture1D = preload("uid://kwmuc2i4nwli")

func init_bar(max_health: int, health: int = -1) -> void:
	max_value = max_health
	if health == -1:
		update_health(max_health)
	else:
		update_health(health)

func update_health(health: int) -> void:
	value = health
	health_label.text = "%02d / %02d" % [value, max_value]
	
	var fill_style = get_theme_stylebox("fill") as StyleBoxFlat
	fill_style.bg_color = color_ramp.gradient.sample(value / max_value)
