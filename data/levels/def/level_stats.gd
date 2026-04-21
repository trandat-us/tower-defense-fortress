extends Resource
class_name LevelStats

const THREE_TROPHIES_THRESHOLD = 0.8
const TWO_TROPHIES_THRESHOLD = 0.5
const ONE_TROPHY_THRESHOLD = 0.2

signal wave_number_updated(value: int)
signal health_updated(value: int)
signal golds_updated(value: int)
signal tower_quantity_updated(value: int)

@export_range(1, 20, 1, "or_greater", "suffix:hp") var max_health: int = 20
@export_range(1, 15, 1, "or_greater") var max_towers: int = 4
@export_range(1, 500, 1, "or_greater", "suffix:golds") var initial_golds: int = 250

var max_wave: int
var wave_number: int:
	set(value):
		wave_number = max(1, value)
		wave_number_updated.emit(wave_number)
var health: int:
	set(value):
		health = clampi(value, 0, max_health)
		health_updated.emit(health)
var golds: int:
	set(value):
		golds = maxi(0, value)
		golds_updated.emit(golds)
var tower_quantity: int:
	set(value):
		tower_quantity = clampi(value, 0, max_towers)
		tower_quantity_updated.emit(tower_quantity)

func _init() -> void:
	init_data.call_deferred()

func init_data(_health: int = -1) -> void:
	if _health <= -1:
		health = max_health
	else:
		health = _health
	golds = initial_golds
	wave_number = 1
	tower_quantity = 0

func get_trophies() -> int:
	var health_percent = float(health) / max_health
	if health_percent >= THREE_TROPHIES_THRESHOLD:
		return 3
	elif health_percent >= TWO_TROPHIES_THRESHOLD:
		return 2
	elif health_percent >= ONE_TROPHY_THRESHOLD:
		return 1
	return 0
