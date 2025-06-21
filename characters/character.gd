extends Node2D
class_name Character

@export var title := ""
@export var equipped_weapon := " "
@export var equipped_armor := " "
@export var current_hp := 100
@export var max_hp := 1
@export var strength := 0 + weapon_strength + armor_strength
@export var defense := 0 + armor_defence
@export var magic := 0 + armor_magic_strength
@export var uses_magic := false
@export_color_no_alpha var main_color := Color.WHITE
@export_color_no_alpha var icon_color := Color.GRAY
@export var icon: Texture2D = preload("res://ui/battle/char_menu/res/sample_char_icon.png")

var alive := true
var defending := false
signal health_changed(p_new_health: int)
signal act_finished
signal item_used
signal spare_finished
signal faint_finished

@export_node_path("Sprite2D") var main_sprite
var sprite: Sprite2D
var mat: ShaderMaterial

func _ready() -> void:
	if !main_sprite:
		return
	sprite = get_node(main_sprite)
	mat = ShaderMaterial.new()
	mat.shader = preload("res://characters/generic_character.gdshader")
	sprite.material = mat
	await get_tree().create_timer(randf_range(0.0, 0.6)).timeout
	idle()

## Override function
func get_acts() -> Array[Act]:
	return [Act.new("Check")]

## Override function
func get_spells() -> Array[Spell]:
	var nothing := Spell.new()
	nothing.title = "Nothing spell"
	nothing.tp_cost = 15
	return [nothing]

func idle() -> void:
	pass

func prep_attack() -> void:
	pass

func do_attack(p_monster: Monster, p_damage: int) -> void:
	if p_monster and !p_monster.dying:
		p_monster.take_damage(self, p_damage)
		p_monster.damage_or_die_animation()
		Sounds.play("snd_laz_c")

func hurt(p_damage: int) -> void:
	p_damage = int(maxi(1, p_damage - 3 * defense) * (1.0 if !defending else 2.0 / 3.0))
	current_hp -= p_damage
	health_changed.emit(current_hp)
	create_text(str(p_damage), Color.WHITE)
	Sounds.play("snd_hurt1")
	if current_hp < 0:
		faint()

func faint() -> void:
	alive = false
	faint_finished.emit()

func heal(p_amount: int) -> void:
	current_hp += p_amount
	Sounds.play("snd_power")
	if !alive and current_hp > 0:
		revive()
	if current_hp >= max_hp:
		current_hp = max_hp
		create_text("MAX", Global.GREEN)
	else:
		create_text(str(p_amount), icon_color)
	health_changed.emit(current_hp)

func revive() -> void:
	if current_hp < max_hp * 0.17:
		current_hp = ceili(max_hp * 0.17)
	alive = true
	idle()

func prep_act() -> void:
	pass

func do_act(_p_monster: Monster, _p_act: int) -> void:
	Global.display_text.emit(title + " did nothing...", true)
	await Global.text_finished
	act_finished.emit()

func prep_item() -> void:
	pass

func use_item(p_character: Character, p_item: int) -> void:
	var item := Global.items[p_item]
	if item == null:
		Global.display_text.emit(title + " tried to use an item that was already used", true)
		await Global.text_finished
		item_used.emit()
		return
	match item.type:
		Item.TYPE.NONE:
			Global.display_text.emit("  * " + title + " used the " + item.name + ".", true)
			await Global.text_finished
			await get_tree().create_timer(0.01).timeout
			Global.display_text.emit("  * But nothing happened...", true)
		Item.TYPE.HEAL:
			p_character.heal(item.amount)
			Global.display_text.emit("  * " + title + " used the " + item.name + "!", true)
			Global.delete_item(p_item)
		Item.TYPE.WEAPON:
			p_character.equipped_weapon == name
			Global.display_text.emit("  * " + title + " equipped the " + item.name + "!", true)
			Global.delete_item(p_item)
		Item.TYPE.ARMOR:
			p_character.equipped_weapon == name
			Global.display_text.emit("  * " + title + " equipped the " + item.name + "!", true)
			Global.delete_item(p_item)
	await Global.text_finished
	item_used.emit()

func unequip_item(p_character, p_item) -> void:
	if item == null:
		Global.display_text.emit(title + " but there was nothing to unequip", true)
		await Global.text_finished
		item_used.emit()
	match item.type:
		item.TYPE.WEAPON:
			items.append(equipped_weapon)
			p_character.equipped_weapon == " "
			Global.display_text.emit("  * " + title + " unequipped the " + item.name + ".", true)
		item.TYPE.ARMOR:
			items.append(equipped_armor)
			p_character.equipped_armor == " "
			Global.display_text.emit("  * " + title + " unequipped the " + item.name + ".", true)
		await Global.text_finished



func prep_spare() -> void:
	pass

func do_spare(p_monster: Monster) -> void:
	if p_monster.mercy_percent >= 1.0:
		p_monster.spare()
		await get_tree().create_timer(0.01).timeout
		Global.display_text.emit("  * " + title + " spared " + p_monster.title + "!", true)
		await Global.text_finished
		Sounds.play("snd_spare")
	else:
		await get_tree().create_timer(0.01).timeout
		Global.display_text.emit("  * " + title + " tried to spare " + p_monster.title + ", but couldn't...", true)
		await Global.text_finished
	spare_finished.emit()

func defend() -> void:
	defending = true

func set_selected(p_selected: bool) -> void:
	if !mat:
		return
	mat.set_shader_parameter("flash", float(p_selected))

func create_text(p_text: String, p_color: Color) -> void:
	var new_text := preload("res://ui/battle/floating_text/floating_text.tscn").instantiate()
	new_text.initialize(global_position, p_text, p_color)
	get_tree().current_scene.add_child(new_text)
