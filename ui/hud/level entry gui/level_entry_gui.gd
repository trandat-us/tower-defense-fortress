extends Control
class_name LevelEntryGUI

signal entry_started
signal entry_ended

@onready var circle_color_rect: ColorRect = %CircleColorRect
@onready var level_number_label: Label = %LevelNumberLabel
@onready var level_label: Label = %LevelLabel
@onready var level_title_label: Label = %LevelTitleLabel
@onready var click_to_begin_label: Label = %ClickToBeginLabel
@onready var gpu_particles_2d: GPUParticles2D = $MainPanel/GPUParticles2D
@onready var gate_panel_h_box: HBoxContainer = $GatePanelHBox

@export var level_number: int = 1:
	set(value):
		level_number = value
		level_number_label.text = str(level_number)
		level_number_label.pivot_offset = level_number_label.size / 2
@export var level_title: String = "Level Title":
	set(value):
		level_title = value
		level_title_label.text = level_title

var is_closing := false
var click_to_begin_tween: Tween

func _ready() -> void:
	display()

func init_level_info(info: LevelInfo) -> void:
	level_number = info.number
	level_title = info.title

func _reset() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	gate_panel_h_box.set_indexed("theme_override_constants/separation", 0)
	
	level_number_label.scale = Vector2.ONE * 1.4
	level_number_label.modulate.a = 0
	
	circle_color_rect.scale = Vector2.ONE * 0.4
	circle_color_rect.modulate.a = 0
	
	level_label.scale = Vector2.ONE * 1.1
	
	level_title_label.modulate.a = 0
	level_title_label.position.y = 464
	
	click_to_begin_label.modulate.a = 0

func display() -> void:
	_reset()
	entry_started.emit()
	
	var tween = create_tween().set_parallel()
	
	# "Expand" HBox separation
	tween.tween_property(gate_panel_h_box, "theme_override_constants/separation", 1152, 1.2) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO).set_delay(0.2)
	
	# Number scale down and increase alpha
	tween.tween_property(level_number_label, "scale", Vector2.ONE, 0.5) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_delay(0.7)
	tween.tween_property(level_number_label, "modulate:a", 1.0, 0.4).set_delay(0.7)
	
	# Circle scale up and increase alpha
	tween.tween_property(circle_color_rect, "scale", Vector2.ONE, 0.5) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_delay(0.7)
	tween.tween_property(circle_color_rect, "modulate:a", 1, 0.4).set_delay(0.7)
	
	# Text "level" scale down
	tween.parallel().tween_property(level_label, "scale", Vector2.ONE, 0.5) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_delay(0.7)
	
	# Emit particles
	tween.tween_callback(gpu_particles_2d.set_indexed.bind("emitting", true)).set_delay(0.7)
	
	# Move level title up and inscrease alpha
	tween.tween_property(level_title_label, "position:y", 432, 0.6) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT).set_delay(1.1)
	tween.tween_property(level_title_label, "modulate:a", 1, 0.5).set_delay(1.1)
	
	# Increase "click to begin" text alpha and enable mouse click
	tween.tween_callback(set_indexed.bind("mouse_filter", Control.MOUSE_FILTER_STOP)).set_delay(1.1)
	tween.tween_property(click_to_begin_label, "modulate:a", 1, 0.9).set_delay(1.1)
	
	# Make "click to begin" text flicker
	tween.tween_callback(func():
		click_to_begin_tween = create_tween().set_loops()
		click_to_begin_tween.tween_property(click_to_begin_label, "modulate:a", 0.7, 1.5)
		click_to_begin_tween.tween_property(click_to_begin_label, "modulate:a", 1, 1.5)
	).set_delay(1.1)

func close() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, 0.7)
	tween.tween_callback(set_indexed.bind("visible", false))
	tween.tween_callback(func(): 
		entry_ended.emit()
		queue_free()
	)

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse_click") and not is_closing:
		is_closing = true
		close()
