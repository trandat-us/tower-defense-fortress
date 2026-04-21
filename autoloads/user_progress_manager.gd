extends Node

const PROGRESS_FILE_PATH = "user://progress.tres"

func _ready() -> void:
	if not FileAccess.file_exists(PROGRESS_FILE_PATH):
		var level_1 := LevelDatabase.get_level(1)
		var level_1_uid := ResourceUID.path_to_uid(level_1.resource_path)
		var level_1_progress = LevelProgress.new()
		level_1_progress.set_progress(level_1_uid, true)
		
		var user_progress = UserProgress.new()
		if user_progress.update_level_progress(level_1_progress):
			ResourceSaver.save(user_progress, PROGRESS_FILE_PATH)

func update_level_passed(number: int, gained_trophies: int) -> void:
	var level_uid := LevelDatabase.get_level_uid(number)
	if level_uid.is_empty():
		return
	
	var user_progress := ResourceLoader.load(PROGRESS_FILE_PATH) as UserProgress
	if user_progress.update_level_passed(level_uid, gained_trophies):
		ResourceSaver.save(user_progress, PROGRESS_FILE_PATH)

func unlock_level(number: int) -> void:
	var level_uid := LevelDatabase.get_level_uid(number)
	if level_uid.is_empty():
		return
	
	var level_progress = LevelProgress.new()
	level_progress.set_progress(level_uid, true)
	
	var user_progress := ResourceLoader.load(PROGRESS_FILE_PATH) as UserProgress
	if user_progress.update_level_progress(level_progress):
		ResourceSaver.save(user_progress, PROGRESS_FILE_PATH)

func get_unlocked_levels() -> Dictionary[String, LevelProgress]:
	var user_progress = ResourceLoader.load(PROGRESS_FILE_PATH) as UserProgress
	return user_progress.get_unlocked_levels() 
