extends Node
class_name ControlSoundPlayer

# Predefine StringNames
const BUTTON_HOVERED = &"button_hovered"
const BUTTON_PRESSED = &"button_pressed"

@onready var sounds: Dictionary[StringName, AudioStreamPlayer] = {
	BUTTON_HOVERED: $ButtonHovered,
	BUTTON_PRESSED: $ButtonPressed
}

@export var root_node: Node

func _ready() -> void:
	if root_node == null:
		root_node = get_parent()
	
	await root_node.ready
	_config_control_sounds(root_node)

func _config_control_sounds(node: Node) -> void:
	for child in node.get_children():
		if child is Button:
			child.mouse_entered.connect(_on_button_mouse_entered.bind(child))
			child.pressed.connect(_on_button_pressed.bind(child))
	
		_config_control_sounds(child)

func _on_button_mouse_entered(button: Button) -> void:
	if not button.disabled:
		play(BUTTON_HOVERED)

func _on_button_pressed(button: Button) -> void:
	play(BUTTON_PRESSED)

func play(sound_name: StringName) -> void:
	if sounds.has(sound_name):
		sounds[sound_name].play()
