extends Area3D
class_name TowerProjectile

const MAX_DISTANCE_TO_TARGET = 0.2

@export var speed: float = 8
@onready var projectile_mesh: MeshInstance3D = $ProjectileMesh

var target: Enemy
var time_scale: float = 1.0
var damage: Damage
var _last_target_position: Vector3

func _physics_process(delta: float) -> void:
	if target:
		_last_target_position = target.global_position
	
	_handle_movement(delta)
	
	if global_position.distance_to(_last_target_position) < MAX_DISTANCE_TO_TARGET:
		_on_reach_last_position()

func _on_body_entered(body: Node3D) -> void:
	if target == body:
		_on_hit_target()

# Handle projectile movement
func _handle_movement(delta: float) -> void:
	pass

# Called when projectile actually hit target
func _on_hit_target() -> void:
	pass

# Called when projectile reach last position of target, this's useful for target died before getting hit
func _on_reach_last_position() -> void:
	pass
