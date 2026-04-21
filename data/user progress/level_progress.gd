extends Resource
class_name LevelProgress

@export var level_uid: String
@export var unlocked: bool = false
@export var passed: bool = false
@export var gained_trophies: int = 0

func set_progress(
	p_uid: String, 
	p_unlocked: bool = false, 
	p_passed: bool = false, 
	p_gained_trophies: int = 0
) -> void:
	level_uid = p_uid
	unlocked = p_unlocked
	passed = p_passed
	gained_trophies = p_gained_trophies

func is_valid() -> bool:
	var path := ResourceUID.uid_to_path(level_uid)
	if path.is_empty():
		return false
	
	if not ResourceLoader.exists(path):
		return false
	
	var res = ResourceLoader.load(path)
	return res.is_class(get_class())
