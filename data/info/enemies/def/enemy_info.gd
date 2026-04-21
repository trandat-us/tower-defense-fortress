extends EntityInfo
class_name EnemyInfo

signal health_changed(value: int)

@export_group("Base Attributes")
@export_range(1, 500, 1, "or_greater", "suffix:hp") var max_health: int = 70
@export_range(0.01, 10, 0.01, "or_greater", "hide_control") var speed: float = 1
@export_range(1, 20, 1, "or_greater", "suffix:golds") var dropped_golds: int = 20
var health: int:
	set(value):
		health = clampi(value, 0, max_health)
		health_changed.emit(health)

@export_group("Attributes Growth Curves")
@export var max_health_curve: Curve
@export var dropped_golds_curve: Curve

@export_group("Progress")
@export_range(1, 10, 1, "or_greater") var max_level: int = 10
var level: int = 1:
	set(value):
		level = clampi(value, 1, max_level)
		_adjust_attributes_to_level()

func init_attributes(_level: int = 1) -> void:
	level = _level
	health = max_health

func _adjust_attributes_to_level() -> void:
	var level_remap := remap(level, 1, max_level, 0, 1)
	
	var max_hp_scale := max_health_curve.sample(level_remap)
	max_health = ceili(max_health * max_hp_scale)
	
	var golds_scale := dropped_golds_curve.sample(level_remap)
	dropped_golds = ceili(dropped_golds * golds_scale)
