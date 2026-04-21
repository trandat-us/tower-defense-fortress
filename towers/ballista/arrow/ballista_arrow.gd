extends TowerProjectile
class_name BallistaArrow

func _handle_movement(delta: float) -> void:
	look_at(_last_target_position)
	global_position = global_position.move_toward(_last_target_position, delta * speed * time_scale)

func _on_hit_target() -> void:
	target.take_damage(damage)
	queue_free()

func _on_reach_last_position() -> void:
	queue_free()
