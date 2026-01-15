extends Node2D
class_name AbstractFighter

enum Stats {
	MAX_HP,
	DEFENSE,
	ATTACK,
	MAGIC,
	MONEY_MULTIPLIER
}

static var FALLBACK_STATS : Dictionary[Stats, int] = {
	Stats.MAX_HP: 100,
	Stats.DEFENSE: 0,
	Stats.ATTACK: 0,
	Stats.MAGIC: 0,
	Stats.MONEY_MULTIPLIER: 1}

signal health_changed(p_new_health: int)

@export var title := ""

var current_hp := 0
@export var base_fighter_stats : Dictionary[Stats, int] = {}:
		set(value):
			current_hp = value.get_or_add(Stats.MAX_HP, 0)
			base_fighter_stats = value

@export var weapon: Equippable
@export var armors: Array[Equippable]

@export_node_path("Sprite2D") var main_sprite: NodePath
var sprite: Sprite2D
var mat: ShaderMaterial

func create_shader(shaderName : String) -> void:
	if !main_sprite:
		return
	sprite = get_node(main_sprite)
	mat = ShaderMaterial.new()
	mat.shader = load("res://fighters/shaders/" + shaderName +".gdshader")
	sprite.material = mat
	await get_tree().create_timer(randf_range(0.0, 0.6)).timeout

func create_text(p_text: String, p_color: Color) -> void:
	var new_text := preload("res://ui/battle/floating_text/floating_text.tscn").instantiate()
	new_text.initialize(global_position, p_text, p_color)
	get_tree().current_scene.add_child(new_text)

func get_value_from_stat(stat : Stats) -> int:
	var finalValue : int = base_fighter_stats.get(stat, FALLBACK_STATS.get(stat))
	for armor : Equippable in armors:
		finalValue += armor.fighter_stat_modifiers.get(stat, 0)
	return finalValue

func get_strength() -> int:
	return get_value_from_stat(Stats.ATTACK)

func get_max_hp() -> int:
	return get_value_from_stat(Stats.MAX_HP)

func get_magic() -> int:
	return get_value_from_stat(Stats.MAGIC)

func get_defense() -> int:
	return get_value_from_stat(Stats.DEFENSE)
