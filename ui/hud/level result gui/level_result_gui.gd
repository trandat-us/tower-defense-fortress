extends Control
class_name LevelResultGUI

const MOVE_UP_LENGTH = 16

@onready var blurry_bg: ColorRect = %BlurryBG
@onready var panel_bg: Panel = %PanelBG
@onready var result_label: Label = %ResultLabel
@onready var level_label: Label = %LevelLabel
@onready var trophies_h_box: TrophiesHBox = $TrophiesHBox
@onready var lose_icon: TextureRect = $LoseIcon

@onready var buttons_h_box: HBoxContainer = $ButtonsHBox
@onready var retry_button: Button = %RetryButton
@onready var main_menu_button: Button = %MainMenuButton
@onready var next_level_button: Button = %NextLevelButton

@onready var level_success_audio: AudioStreamPlayer = $LevelSuccessAudio
@onready var level_failed_audio: AudioStreamPlayer = $LevelFailedAudio

var icon_label: Label
var number: int
var result_audio: AudioStreamPlayer
var blurry_bg_mat: ShaderMaterial:
	get:
		return blurry_bg.material

func _ready() -> void:
	lose_icon.pivot_offset = lose_icon.size / 2
	visible = false

func _reset() -> void:
	blurry_bg_mat.set_shader_parameter("blur_amount", 0)
	panel_bg.modulate.a = 0
	
	lose_icon.scale = Vector2.ONE * 1.5
	lose_icon.modulate.a = 0
	
	trophies_h_box.modulate.a = 0
	
	result_label.position.y += MOVE_UP_LENGTH
	result_label.modulate.a = 0
	
	level_label.modulate.a = 0
	
	buttons_h_box.position.y += MOVE_UP_LENGTH
	buttons_h_box.modulate.a = 0
	buttons_h_box.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED

func _set_result(success: bool) -> void:
	if success:
		trophies_h_box.visible = true
		lose_icon.visible = false
		
		result_label.text = "VICTORY !"
		
		next_level_button.visible = true
		
		result_audio = level_success_audio
	else:
		trophies_h_box.visible = false
		lose_icon.visible = true
		
		result_label.text = "DEFEATED"
		
		next_level_button.visible = false
		
		result_audio = level_failed_audio

func init_level_info(info: LevelInfo) -> void:
	number = info.number
	level_label.text = "Level %d  •  %s" % [number, info.title]

func display(success: bool, trophies: int) -> void:
	_set_result(success)
	_reset()
	visible = true
	
	var tween = create_tween()
	# Increase panel alpha and blur amount
	tween.tween_property(blurry_bg_mat, "shader_parameter/blur_amount", 3, 0.5)
	tween.parallel().tween_property(panel_bg, "modulate:a", 1.0, 0.5)
	if success:
		# Show gained trophies
		tween.tween_property(trophies_h_box, "modulate:a", 1, 0.4).set_delay(0.1)
		tween.tween_callback(func():
			result_audio.play()
			trophies_h_box.display(trophies)
			if trophies > 0:
				tween.pause()
				trophies_h_box.animation_finished.connect(func(): tween.play(), CONNECT_ONE_SHOT)
		)
	else:
		# Show skull icon
		tween.tween_property(lose_icon, "scale", Vector2.ONE, 0.4) \
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
		tween.parallel().tween_property(lose_icon, "modulate:a", 1, 0.4)
		tween.parallel().tween_callback(result_audio.play)
	
	# Move result label up and increase alpha
	tween.tween_property(result_label, "position:y", result_label.position.y - MOVE_UP_LENGTH, 0.2) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_delay(0.1)
	tween.parallel().tween_property(result_label, "modulate:a", 1, 0.2)
	# Increase level label (number + title) alpha
	tween.tween_property(level_label, "modulate:a", 1, 0.2)
	# Move buttons up, increase alpha and enable mouse click
	tween.tween_property(buttons_h_box, "position:y", buttons_h_box.position.y - MOVE_UP_LENGTH, 0.2) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_delay(0.1)
	tween.parallel().tween_property(buttons_h_box, "modulate:a", 1, 0.2)
	tween.tween_callback(func(): buttons_h_box.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_ENABLED)

func _on_retry_button_pressed() -> void:
	get_tree().reload_current_scene()

func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/main menu/main_menu.tscn")

func _on_next_level_button_pressed() -> void:
	var next_level = LevelDatabase.get_level(number + 1)
	if next_level:
		get_tree().change_scene_to_file(next_level.scene)
