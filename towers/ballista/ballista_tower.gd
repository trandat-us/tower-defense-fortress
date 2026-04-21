extends Tower
class_name BallistaTower

const BALLISTA_ARROW = preload("uid://c74nwpv56eb23")

@onready var shoot_anim_player: AnimationPlayer = %ShootAnimPlayer
@onready var shoot_position: Marker3D = %ShootPosition

func _on_looked_at_target() -> void:
	if not reload_timer.is_running:
		shoot_anim_player.play("shoot")

func _shoot_arrow() -> void:
	if not target:
		return
	
	var map = get_tree().get_first_node_in_group("map")
	if map:
		var arrow = BALLISTA_ARROW.instantiate() as BallistaArrow
		arrow.target = target
		arrow.damage = damage
		arrow.time_scale = time_scale
		map.add_child(arrow)
		arrow.global_position = shoot_position.global_position
		arrow.global_rotation = shoot_position.global_rotation
#
func _on_set_time_scale() -> void:
	shoot_anim_player.speed_scale = time_scale
