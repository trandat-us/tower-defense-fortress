extends Node

func create_3d_audio_from_scene(scene_uid: String, source: Node3D = null, scene_group_to_add: String = "map") -> void:
	if not FileAccess.file_exists(scene_uid):
		return
	
	var audio_scene = load(scene_uid)
	if not audio_scene is PackedScene:
		return
	
	var audio = audio_scene.instantiate()
	if not audio is AudioStreamPlayer3D:
		audio.queue_free()
		return
	
	var map = get_tree().get_first_node_in_group(scene_group_to_add)
	if map:
		map.add_child(audio)
		if source:
			audio.global_position = source.global_position
		
		audio.play()
		audio.finished.connect(audio.queue_free)
