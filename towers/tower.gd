extends StaticBody3D
class_name Tower

const AIM_LERP_SPEED = 16.0

# Placeable Plane Colors
const PLACEABLE_COLOR = [Color(0.0, 0.561, 0.0, 0.349), Color(0.0, 0.561, 0.0)]
const UNPLACEABLE_COLOR = [Color(0.855, 0.0, 0.0, 0.349), Color(0.855, 0.0, 0.0)]

# Mesh nodes
@onready var equipment_base: MeshInstance3D = %EquipmentBase
@onready var emplacement: MeshInstance3D = %Emplacement
@onready var weapon: MeshInstance3D = %Weapon
@onready var attack_range_visual: MeshInstance3D = %AttackRangeVisual
@onready var selection_mesh: MeshInstance3D = $SelectionMesh
@onready var placeable_plane: MeshInstance3D = $PlaceablePlane
# Other nodes
@onready var enemy_detector_shape: CollisionShape3D = %EnemyDetectorShape
@onready var focus_audio: AudioStreamPlayer = $FocusAudio

@export var active: bool = false
@export var info: TowerInfo

var in_range_enemies: Array[Enemy]
var target: Enemy
var damage: Damage
var reload_timer: SceneTimer
var time_scale: float = 1.0:
	set(value):
		time_scale = value
		_on_set_time_scale()

# Getter-only attributes
var max_health: int:
	get:
		return info.get_attribute(AttributeNames.MAX_HEALTH)
var attack_damage: int:
	get:
		return info.get_attribute(AttributeNames.ATTACK_DAMAGE)
var attack_range: float:
	get:
		return info.get_attribute(AttributeNames.ATTACK_RANGE)
var reload_times: float:
	get:
		return info.get_attribute(AttributeNames.RELOAD_TIMES)

# Internal variables
var _alpha_tween: Tween
var _selection_mesh_tween: Tween

func _ready() -> void:
	selection_mesh.visible = false
	info = info.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	
	info.health = max_health
	_adjust_attack_range(attack_range)
	reload_timer = SceneTimer.new(reload_times)
	damage = Damage.new(self, attack_damage)

func _process(delta: float) -> void:
	reload_timer.tick(delta * time_scale)

func _physics_process(delta: float) -> void:
	if not active or not target:
		return
	
	var target_direction := target.global_position - weapon.global_position
	var emplacement_angle := atan2(target_direction.x, target_direction.z)
	
	emplacement.rotation.y = lerp_angle(emplacement.rotation.y, emplacement_angle, delta * AIM_LERP_SPEED * time_scale)
	if abs(angle_difference(emplacement_angle, emplacement.rotation.y)) < 0.05:
		_on_looked_at_target()

func _on_enemy_detector_area_body_entered(body: Node3D) -> void:
	in_range_enemies.append(body)
	if not target:
		target = body

func _on_enemy_detector_area_body_exited(body: Node3D) -> void:
	in_range_enemies.erase(body)
	if in_range_enemies.is_empty():
		target = null
	else:
		target = in_range_enemies[0]

func _adjust_attack_range(r: float) -> void:
	if r <= 0:
		return
	
	enemy_detector_shape.shape.radius = r
	attack_range_visual.mesh.size = Vector2.ONE * r * 2

func _set_visual_attack_range_alpha(alpha: float) -> void:
	attack_range_visual.material_override.set_shader_parameter("alpha", alpha)

func _set_selection_mesh_alpha(alpha: float) -> void:
	selection_mesh.transparency = 1.0 - alpha

func level_up() -> void:
	if info.level == info.max_level:
		return
	
	var prev_max_hp := max_health
	info.level += 1
	if info.health == prev_max_hp:
		info.health = max_health
	_adjust_attack_range(attack_range)
	reload_timer.duration = reload_times
	damage = Damage.new(self, attack_damage)

func focus() -> void:
	focus_audio.play()
	
	if _alpha_tween:
		_alpha_tween.kill()
	
	selection_mesh.visible = true
	
	_alpha_tween = create_tween().set_parallel()
	_alpha_tween.tween_method(_set_visual_attack_range_alpha, 0.0, 1.0, 0.2)
	_alpha_tween.tween_method(_set_selection_mesh_alpha, 0.0, 1.0, 0.2)
	
	_selection_mesh_tween = create_tween().set_loops()
	_selection_mesh_tween.tween_property(selection_mesh, "scale", Vector3.ONE * Vector3(1.1, 1.0, 1.1), 0.4)
	_selection_mesh_tween.tween_property(selection_mesh, "scale", Vector3.ONE, 0.4)

func un_focus() -> void:
	if _alpha_tween:
		_alpha_tween.kill()
	
	_alpha_tween = create_tween()
	_alpha_tween.parallel().tween_method(_set_visual_attack_range_alpha, 1.0, 0.0, 0.2)
	_alpha_tween.parallel().tween_method(_set_selection_mesh_alpha, 1.0, 0.0, 0.2)
	_alpha_tween.tween_callback(
		func():
			if _selection_mesh_tween:
				_selection_mesh_tween.kill()
			selection_mesh.visible = false
			selection_mesh.scale = Vector3.ONE
	)

func on_place(speed_scale: float = 1) -> void:
	un_focus()
	active = true
	time_scale = speed_scale
	placeable_plane.queue_free()

func display_placeable_plane(placeable: bool) -> void:
	if placeable:
		placeable_plane.material_override.set("shader_parameter/color_gap", PLACEABLE_COLOR[0])
		placeable_plane.material_override.set("shader_parameter/color_stripe", PLACEABLE_COLOR[1])
	else:
		placeable_plane.material_override.set("shader_parameter/color_gap", UNPLACEABLE_COLOR[0])
		placeable_plane.material_override.set("shader_parameter/color_stripe", UNPLACEABLE_COLOR[1])

func start_reload_timer() -> void:
	reload_timer.start()

func _on_looked_at_target() -> void:
	pass

func _on_set_time_scale() -> void:
	pass
