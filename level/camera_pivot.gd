extends Node3D
class_name CameraPivot

const MOVEMENT_SPEED = 5.0
const ZOOM_SPEED = 8.0

@onready var spring_arm_3d: SpringArm3D = $SpringArm3D

@export var top_left_limit: Marker3D
@export var bottom_right_limit: Marker3D

@export_range(0.1, 15, 0.1, "or_greater", "suffix:m") var zoom_min: float = 5
@export_range(0.1, 15, 0.1, "or_greater", "suffix:m") var zoom_max: float = 12
@export_range(0.1, 1, 0.1, "or_greater", "suffix:m") var zoom_step: float = 0.5

@export var movement_locked: bool = false
@export var zoom_locked: bool = false
var spring_length := -INF

func _ready() -> void:
	spring_length = clampf(spring_arm_3d.spring_length, zoom_min, zoom_max)

func _process(delta: float) -> void:
	_move_by_input(delta)
	_zoom(delta)

func _unhandled_input(event: InputEvent) -> void:
	if not zoom_locked:
		if event.is_action_pressed("wheel_up"):
			spring_length = clampf(spring_length - zoom_step, zoom_min, zoom_max)
		if event.is_action_pressed("wheel_down"):
			spring_length = clampf(spring_length + zoom_step, zoom_min, zoom_max)

func _move_by_input(delta: float) -> void:
	if not movement_locked:
		var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
		var direction := Vector3(input_dir.x, 0, input_dir.y).normalized()
		var pos_x = position.x + direction.x * MOVEMENT_SPEED * delta
		var pos_z = position.z + direction.z * MOVEMENT_SPEED * delta
		
		position.x = clampf(pos_x, top_left_limit.global_position.x, bottom_right_limit.global_position.x)
		position.z = clampf(pos_z, top_left_limit.global_position.z, bottom_right_limit.global_position.z)

func _zoom(delta: float) -> void:
	if spring_length == spring_arm_3d.spring_length:
		return
	spring_arm_3d.spring_length = lerp(spring_arm_3d.spring_length, spring_length, delta * ZOOM_SPEED)

func lock_movement() -> void:
	movement_locked = true

func lock_zoom() -> void:
	zoom_locked = true

func lock() -> void:
	lock_movement()
	lock_zoom()

func unlock_movement() -> void:
	movement_locked = false

func unlock_zoom() -> void:
	zoom_locked = false

func unlock() -> void:
	unlock_movement()
	unlock_zoom()

func move_to_position(pos: Vector3) -> void:
	lock()
	var tween = create_tween()
	tween.tween_property(self, "position", Vector3(pos.x, 0, pos.z), 0.3)
	tween.tween_callback(unlock)
