extends Item
class_name Equippable

enum Category {
	SWORD,
	SCARF,
	AXE,
	ARMOR,
	LIGHT_ARMOR
}

@export var category : Category
@export var fighter_stat_modifiers : Dictionary[AbstractFighter.Stats, int]
@export var attributes : Dictionary[EquippableAttribute, int]

##Map of character titles and their reactions upon receiving this piece of equipment.
@export var fighter_equip_reactions : Dictionary[String, String]
