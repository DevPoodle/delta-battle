extends Resource
class_name Item

enum TYPE {
	NONE, HEAL, WEAPON, ARMOR
}

@export var name := "Item"
@export var short_description := ""
@export_multiline var long_description := ""
@export var type := TYPE.NONE
@export var amount := 0

if item.TYPE.WEAPON:
	@export var weapon_strength := 0

if item.TYPE.ARMOR:
	@export var armor_defence := 0
	@export var armor_magic_strength := 0
	@export var armor_strength := 0