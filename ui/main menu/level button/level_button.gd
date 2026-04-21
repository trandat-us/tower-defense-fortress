extends Button
class_name LevelButton

@onready var lock_icon: TextureRect = %LockIcon
@onready var level_number: Label = %LevelNumber
@onready var level_title: Label = %LevelTitle
@onready var trophies_h_box: TrophiesHBox = %TrophiesHBox

@export var coming_soon: bool = false
@export var level_info: LevelInfo
@export_range(0, 3, 1) var trophies_gained: int = 0

func _ready() -> void:
	if coming_soon:
		disabled = true
		level_number.text = "?"
		level_title.text = "Coming soon"
	elif level_info:
		level_number.text = str(level_info.number)
		level_title.text = str(level_info.title)
	
	if disabled:
		lock_icon.visible = true
		trophies_h_box.visible = false
		
		level_number.add_theme_font_size_override("font_size", 40)
		level_title.add_theme_font_size_override("font_size", 16)
		
		modulate.a = 0.7
	else:
		lock_icon.visible = false
		trophies_h_box.visible = true
		trophies_h_box.display(trophies_gained)
		
		level_number.add_theme_font_size_override("font_size", 48)
		level_title.add_theme_font_size_override("font_size", 24)
		
		modulate.a = 1

func _on_pressed() -> void:
	get_tree().change_scene_to_file(level_info.scene)
