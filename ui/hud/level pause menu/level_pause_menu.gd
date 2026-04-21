extends Control
class_name LevelPauseMenu

const MAIN_PANEL_Y_OFFSET = 256
const VISUALIZING_DURATION = 0.3

@onready var main_panel: Panel = $MainPanel
@onready var color_bg: ColorRect = $ColorBG

var animation_tween: Tween

func _ready() -> void:
	visible = false
	main_panel.modulate.a = 0
	main_panel.position.y += MAIN_PANEL_Y_OFFSET
	LevelEvents.level_paused.connect(_on_paused)

func open() -> void:
	get_tree().paused = true
	
	visible = true
	animation_tween = create_tween()
	animation_tween.tween_method(_set_bg_color_blur_amount, 0.0, 1.0, VISUALIZING_DURATION)
	animation_tween.parallel().tween_property(main_panel, "modulate:a", 1.0, VISUALIZING_DURATION).set_ease(Tween.EASE_OUT)
	animation_tween.parallel().tween_property(main_panel, "position:y", main_panel.position.y - MAIN_PANEL_Y_OFFSET, VISUALIZING_DURATION) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	animation_tween.tween_callback(func(): 
		animation_tween.kill()
		animation_tween = null
	)

func close() -> void:
	animation_tween = create_tween()
	animation_tween.tween_method(_set_bg_color_blur_amount, 1.0, 0.0, VISUALIZING_DURATION)
	animation_tween.parallel().tween_property(main_panel, "modulate:a", 0.0, VISUALIZING_DURATION).set_ease(Tween.EASE_IN)
	animation_tween.parallel().tween_property(main_panel, "position:y", main_panel.position.y + MAIN_PANEL_Y_OFFSET, VISUALIZING_DURATION) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	
	animation_tween.tween_callback(func(): 
		animation_tween.kill()
		animation_tween = null
		visible = false
		
		await get_tree().create_timer(0.2).timeout
		get_tree().paused = false
	)

func _on_paused() -> void:
	if not animation_tween:
		open()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and visible:
		close()

func _set_bg_color_blur_amount(value: float) -> void:
	color_bg.material.set_shader_parameter("blur_amount", value)

func _on_resume_button_pressed() -> void:
	if not animation_tween:
		close()

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_settings_button_pressed() -> void:
	pass # Replace with function body.

func _on_exit_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://ui/main menu/main_menu.tscn")
