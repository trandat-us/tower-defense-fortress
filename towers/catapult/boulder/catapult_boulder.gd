extends TowerProjectile
class_name CatapultBoulder

const HIT_AUDIO = "uid://cn2sdby4p84od"

@export_range(0.01, 10, 0.01, "or_greater", "suffix:m") var peak_height: float = 1.0

var throwed: bool = false
var travel_progress: float = 0.0
var origin: Vector3

var aoe_radius: float
var aoe_falloff: Curve

func _physics_process(delta: float) -> void:
	if not throwed:
		return
	
	super._physics_process(delta * time_scale)

func _handle_movement(delta: float) -> void:
	var self_xz := Vector2(global_position.x, global_position.z)
	var target_xz := Vector2(_last_target_position.x, _last_target_position.z)
	var target_normal := (target_xz - self_xz).normalized()
	
	var cur_xz_dist := self_xz.distance_to(target_xz)
	var origin_xz := Vector2(origin.x, origin.z)
	var total_xz := origin_xz.distance_to(target_xz)
	travel_progress = 1.0 - clampf(cur_xz_dist / total_xz, 0.0, 1.0)
	
	var y_linear = origin.y + (_last_target_position.y - origin.y) * travel_progress
	var y_offset = peak_height * 4 * travel_progress * (1.0 - travel_progress)
	
	global_position.x += target_normal.x * speed * delta
	global_position.z += target_normal.y * speed * delta
	global_position.y = y_linear + y_offset
	projectile_mesh.global_rotation.z += speed * delta

func _on_hit_target() -> void:
	AudioManager.create_3d_audio_from_scene(HIT_AUDIO, self)
	_deal_aoe_damage()
	queue_free()

func _on_reach_last_position() -> void:
	AudioManager.create_3d_audio_from_scene(HIT_AUDIO, self)
	_deal_aoe_damage()
	queue_free()

func _deal_aoe_damage() -> void:
	var params = PhysicsShapeQueryParameters3D.new()
	var shape = CylinderShape3D.new()
	shape.height = 0.2
	shape.radius = aoe_radius
	
	params.shape = shape
	params.collision_mask = collision_mask
	params.transform = Transform3D(Basis.IDENTITY, global_position)
	
	var space = get_world_3d().direct_space_state
	var result = space.intersect_shape(params)
	
	if result.size() > 0:
		for collision in result:
			var collider = collision["collider"] as Node3D
			if not collider is Enemy:
				continue
			
			var offset := global_position.distance_to(collider.global_position) / aoe_radius
			var damage_ratio := aoe_falloff.sample(offset)
			var actual_damage = Damage.new(damage.attacker, ceili(damage.damage * damage_ratio))
			collider.take_damage(actual_damage)

func throw_at(t: Node3D) -> void:
	if t:
		target = t
		_last_target_position = target.global_position
		throwed = true
		origin = global_position
