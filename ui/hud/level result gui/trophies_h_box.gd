extends HBoxContainer
class_name TrophiesHBox

signal animation_finished

@export var animation: bool = true

var trophy_silhouettes: Array[TrophySilhouette]

func _ready() -> void:
	for child in get_children():
		if child is TrophySilhouette:
			trophy_silhouettes.append(child)

func display(trophies: int = 0) -> void:
	trophies = clampi(trophies, 0, 3)
	for i in range(trophies):
		trophy_silhouettes[i].display(animation)
		if animation:
			await trophy_silhouettes[i].animation_finished
	animation_finished.emit()
