extends Tower
class_name CatapultTower

const CATAPULT_BOULDER = preload("uid://qcg3j2ck0dkt")

@onready var throw_anim_player: AnimationPlayer = %ThrowAnimPlayer
@onready var boulder_transform: Marker3D = %BoulderTransform

var inner_enemies: Array[Enemy]
var boulder: CatapultBoulder

var min_range: float:
	get:
		return info.get_attribute(AttributeNames.MIN_RANGE)
var aoe_radius: float:
	get:
		return info.get_attribute(AttributeNames.AOE_RADIUS)
var aoe_falloff: Curve:
	get:
		return info.get_attribute(AttributeNames.AOE_FALLOFF)

var _reloading_tween: Tween = null

func _ready() -> void:
	super._ready()
	boulder = weapon.get_node("CatapultBoulder")
	attack_range_visual.material_override.set_shader_parameter("inner_radius", min_range / attack_range)

func _process(delta: float) -> void:
	for e in inner_enemies:
		if e and _get_xz_distance(weapon.global_position, e.global_position) >= min_range:
			_on_enemy_detector_area_body_entered(e)
			inner_enemies.erase(e)
	
	for e in in_range_enemies:
		if e and _get_xz_distance(weapon.global_position, e.global_position) < min_range:
			_on_enemy_detector_area_body_exited(e)
			inner_enemies.append(e)

func _get_xz_distance(from: Vector3, to: Vector3) -> float:
	return Vector2(from.x, from.z).distance_to(Vector2(to.x, to.z))

func _on_looked_at_target() -> void:
	if boulder:
		throw_anim_player.play("throw")

func _throw_boulder() -> void:
	if not target:
		return
	
	var map = get_tree().get_first_node_in_group("map")
	if map:
		# move boulder to map
		weapon.remove_child(boulder)
		map.add_child(boulder)
		# set transform and throw at target
		boulder.global_transform = boulder_transform.global_transform
		boulder.time_scale = time_scale
		boulder.damage = damage
		boulder.aoe_radius = aoe_radius
		boulder.aoe_falloff = aoe_falloff
		boulder.throw_at(target)
		boulder = null

func _reload_boulder() -> void:
	if not boulder:
		var instance = CATAPULT_BOULDER.instantiate() as CatapultBoulder
		weapon.add_child(instance)
		instance.position = boulder_transform.position
		instance.scale = Vector3.ONE * 0.001
		
		_reloading_tween = create_tween().set_speed_scale(time_scale)
		_reloading_tween.tween_property(instance, "scale", Vector3.ONE, reload_timer.duration)
		_reloading_tween.tween_callback(
			func():
				boulder = instance
				_reloading_tween.kill()
		)

func _on_set_time_scale() -> void:
	throw_anim_player.speed_scale = time_scale
	if _reloading_tween:
		_reloading_tween.set_speed_scale(time_scale)

func level_up() -> void:
	super.level_up()
	attack_range_visual.material_override.set_shader_parameter("inner_radius", min_range / attack_range)
