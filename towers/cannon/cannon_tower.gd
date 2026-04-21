extends Tower
class_name CannonTower

const CANNON_BALL = preload("uid://ub7ivmxk2obq")

@onready var fire_position: Marker3D = %FirePosition
@onready var fire_anim_player: AnimationPlayer = %FireAnimPlayer

func _on_set_time_scale() -> void:
	fire_anim_player.speed_scale = time_scale

func _on_looked_at_target() -> void:
	if not reload_timer.is_running:
		fire_anim_player.play("fire")

func _fire() -> void:
	if not target:
		return
	
	var map = get_tree().get_first_node_in_group("map")
	if map:
		var ball = CANNON_BALL.instantiate() as CannonBall
		ball.damage = damage
		ball.target = target
		ball.time_scale = time_scale
		map.add_child(ball)
		ball.global_position = fire_position.global_position
