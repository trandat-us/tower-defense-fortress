extends Node

const LEVELS_DIR = "res://data/levels/"

var levels: Array[LevelInfo]

func _ready() -> void:
	_load_level_info(LEVELS_DIR, levels)

func _load_level_info(path: String, result: Array) -> void:
	var dir := DirAccess.open(path)
	
	if dir == null:
		push_error("Cannot open folder: " + path)
		return
	
	dir.list_dir_begin()
	var content := dir.get_next()
	
	while content != "":
		if dir.current_is_dir() and not content.begins_with("."):
			_load_level_info(path + "/" + content, result)
		else:
			var full_path := path + content
			
			if full_path.ends_with(".remap"):
				full_path = full_path.trim_suffix(".remap")
			
			if full_path.ends_with(".tres"):
				var file = load(full_path)
				if file and file is LevelInfo:
					result.append(file)
		
		content = dir.get_next()
	
	dir.list_dir_end()

func get_level(number: int) -> LevelInfo:
	for l in levels:
		if l.number == number:
			return l
	return null

func get_level_uid(number: int) -> String:
	for l in levels:
		if l.number == number:
			return ResourceUID.path_to_uid(l.resource_path)
	return ""

func get_level_uids() -> Array[String]:
	var uids: Array[String] = []
	for l in levels:
		uids.append(ResourceUID.path_to_uid(l.resource_path))
	return uids
