extends PathFollow3D
class_name EnemyPathFollow

var enemy: Enemy
var time_scale: float = 1.0

func attach_enemy(
	scene: PackedScene,
	level: int = 1,
	speed_scale: float = 1.0, 
	height_offset: float = 0.0
) -> bool:
	var instance = scene.instantiate()
	if instance is Enemy:
		add_child(instance)
		enemy = instance
		enemy.init_level(level)
		enemy.info.speed = enemy.info.speed * speed_scale
		enemy.position.y += height_offset
		enemy.died.connect(_on_enemy_died)
		return true
	return false

func _process(delta: float) -> void:
	if enemy:
		progress += delta * enemy.info.speed * time_scale
		if progress_ratio == 1.0:
			LevelEvents.an_enemy_reached_end.emit(enemy)
			queue_free()

func _on_enemy_died() -> void:
	LevelEvents.an_enemy_died.emit(enemy)
	queue_free()
