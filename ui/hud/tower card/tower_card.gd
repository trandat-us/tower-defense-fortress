extends Button
class_name TowerCard

signal card_dragged(scene: PackedScene)
signal card_dropped

@onready var tower_icon: TextureRect = %TowerIcon
@onready var name_label: Label = %NameLabel
@onready var cost_label: Label = %CostLabel

@export_group("Tower", "tower_")
@export var tower_scene: PackedScene

@export_group("Hover", "hover_")
@export var hover_scale: float = 1.05
@export_range(0.01, 1, 0.01, "or_greater", "suffix:s") var hover_duration: float = 0.1

var scaling_tween: Tween
var pressing: bool = false
var dragging: bool = false

func _ready() -> void:
	pivot_offset = size / 2

func _process(delta: float) -> void:
	if is_hovered():
		_on_hovered()
	else:
		_on_not_hovered()

func _on_hovered() -> void:
	if scaling_tween and scaling_tween.is_running():
		return
	
	scaling_tween = create_tween().set_parallel(true)
	scaling_tween.tween_property(self, "scale", Vector2.ONE * hover_scale, hover_duration)

func _on_not_hovered() -> void:
	if scaling_tween and scaling_tween.is_running():
		return
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, hover_duration)

func _on_button_down() -> void:
	pressing = true

func _on_button_up() -> void:
	pressing = false
	if dragging:
		LevelEvents.tower_card_dropped.emit()
	dragging = false

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and event.screen_velocity.length() > 20.0 and pressing and not dragging:
		if tower_scene:
			dragging = true
			LevelEvents.tower_card_drag_started.emit(tower_scene)
		else:
			push_warning("Tower scene hasn't been attached to get dragged")
