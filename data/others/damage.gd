extends Resource
class_name Damage

var damage: int
var attacker: Node3D

func _init(_attacker: Node3D = null, _damage: int = 1) -> void:
	attacker = _attacker
	damage = _damage

func area_damage(percent: float = 0.75) -> Damage:
	damage = ceili(damage * percent)
	return self
