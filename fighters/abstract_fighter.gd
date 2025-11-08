extends Node2D
class_name AbstractFighter


signal health_changed(p_new_health: int)

@export var title := ""

@export var current_hp := 100
@export var max_hp := 100
@export var strength := 0:
	get():
		var equipped_strength := 0 if !weapon else weapon.attack
		for armor: Equippable in armors:
			equipped_strength += armor.attack
		return strength + equipped_strength
@export var defense := 0:
	get():
		var equipped_defense := 0 if !weapon else weapon.defense
		for armor: Equippable in armors:
			equipped_defense += armor.defense
		return defense + equipped_defense

@export var weapon: Equippable
@export var armors: Array[Equippable]

func create_text(p_text: String, p_color: Color) -> void:
	var new_text := preload("res://ui/battle/floating_text/floating_text.tscn").instantiate()
	new_text.initialize(global_position, p_text, p_color)
	get_tree().current_scene.add_child(new_text)
