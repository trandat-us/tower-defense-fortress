extends Resource
class_name UserProgress

@export var levels_progress: Dictionary[String, LevelProgress]

func update_level_progress(lp: LevelProgress) -> bool:
	if lp == null or not lp.is_valid():
		return false
	
	if levels_progress.has(lp.level_uid):
		# if cur not passed and lp not passed => do nothing
		# if cur not passed and lp passed => replace cur with lp
		# if cur passed and lp not passed => do nothing
		# if cur passed and lp passed with lp's trophies higher than cur => replace cur with lp
		# if cur passed and lp passed with lp's trophies lower than or equal to cur => do nothing
		if not lp.passed:
			return false
		
		var cur_progress := levels_progress[lp.level_uid]
		if lp.gained_trophies <= cur_progress.gained_trophies:
			return false
	levels_progress[lp.level_uid] = lp
	return true

func update_level_passed(uid: String, gained_trophies: int) -> bool:
	if not levels_progress.has(uid):
		return false
	
	var progress = levels_progress[uid]
	if not progress.unlocked:
		return false
	
	if gained_trophies <= progress.gained_trophies:
		return false
	
	progress.passed = true
	progress.gained_trophies = gained_trophies
	return true

func get_unlocked_levels() -> Dictionary[String, LevelProgress]:
	var unlocked_levels: Dictionary[String, LevelProgress] = {}
	
	for level_uid in levels_progress:
		if levels_progress[level_uid].unlocked:
			unlocked_levels[level_uid] = levels_progress[level_uid].duplicate()
	
	return unlocked_levels
