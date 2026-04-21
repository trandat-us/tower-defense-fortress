extends GridContainer

const LEVEL_BUTTON = preload("uid://cyblixg2yspga")

@export var open_all: bool = false

func _ready() -> void:
	var unlocked_levels := UserProgressManager.get_unlocked_levels()
	var level_uids := LevelDatabase.get_level_uids()
	
	for uid in level_uids:
		var level_info = ResourceLoader.load(uid) as LevelInfo
		var button = LEVEL_BUTTON.instantiate() as LevelButton
		button.level_info = level_info
		
		if unlocked_levels.has(uid):
			button.disabled = false
			button.trophies_gained = unlocked_levels[uid].gained_trophies
		if open_all:
			button.disabled = false
		
		add_child(button)
	
	var cbutton = LEVEL_BUTTON.instantiate() as LevelButton
	cbutton.coming_soon = true
	add_child(cbutton)
