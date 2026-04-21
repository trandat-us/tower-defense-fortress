extends CharacterBody3D
class_name Enemy

signal died

@onready var enemy_health_bar: EnemyHealthBar = %EnemyHealthBar

@export var info: EnemyInfo

var _died_emitted := false

func _ready() -> void:
	info = info.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)

func init_level(level: int = 1) -> void:
	info.init_attributes(level)
	enemy_health_bar.init_bar(info)

func take_damage(damage: Damage) -> void:
	info.health -= damage.damage
	if info.health == 0 and not _died_emitted:
		_died_emitted = true
		died.emit()
