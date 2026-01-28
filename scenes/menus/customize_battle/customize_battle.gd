extends Node2D

var dark_candy := preload("res://holdables/items/dark_candy.tres")

@export var characters: Array[PackedScene] = [preload("res://fighters/characters/blue/blue.tscn")]
@export var enemies: Array[PackedScene] = [preload("res://fighters/monsters/slime/slime.tscn")]
@export var weapons: Array[Equippable] = []
@export var armors: Array[Equippable] = []

var do_focus_noise := true

func _ready() -> void:
	$Main/Start.grab_focus()
	$Heart.position = Vector2(90.0, $Main/Start.global_position.y + 48.0 / 2.0 + 2.0)
	Sounds.set_music("castletown", 0.8)
	get_viewport().gui_focus_changed.connect(on_focus_changed)
	
	var character_names := PackedStringArray(["None"])
	for character: PackedScene in characters:
		character_names.append((character.instantiate() as Character).title)
	for spin_box: CustomSpinBox in $Characters/VBox.get_children():
		spin_box.options = character_names
		spin_box.option = 1
	
	var enemy_names := PackedStringArray(["None"])
	for enemy: PackedScene in enemies:
		enemy_names.append((enemy.instantiate() as Monster).title)
	for spin_box: CustomSpinBox in $Enemies/VBox.get_children():
		spin_box.options = enemy_names
		spin_box.option = 1
	
	var weapon_names := PackedStringArray(["None"])
	for weapon: Equippable in weapons:
		weapon_names.append(weapon.name)
	$Equipment/VBox/Weapon.options = weapon_names
	
	var armor_names := PackedStringArray(["None"])
	for armor: Equippable in armors:
		armor_names.append(armor.name)
	for spin_box: CustomSpinBox in [$Equipment/VBox/Armor1, $Equipment/VBox/Armor2]:
		spin_box.options = armor_names

func on_focus_changed(p_node: Control) -> void:
	$Heart.position = Vector2(90.0, p_node.global_position.y + 48.0 / 2.0 + 2.0)
	if do_focus_noise:
		Sounds.play("snd_menumove")

func _on_start_pressed() -> void:
	Sounds.play("snd_select")
	
	var weapon_option = $Equipment/VBox/Weapon.option
	var weapon := null if weapon_option == 0 else weapons[weapon_option - 1]
	var armor: Array[Equippable] = []
	for spin_box: CustomSpinBox in [$Equipment/VBox/Armor1, $Equipment/VBox/Armor2]:
		if spin_box.option != 0:
			armor.append(armors[spin_box.option - 1])
	
	Global.characters.clear()
	for spin_box: CustomSpinBox in $Characters/VBox.get_children():
		if spin_box.option == 0:
			continue
		var character: Character = characters[spin_box.option - 1].instantiate()
		Global.characters.append(character)
		character.weapon = weapon
		character.armors = armor
	if Global.characters.is_empty():
		Global.characters.append(characters[0].instantiate())
	
	Global.chosen_monsters.clear()
	for spin_box: CustomSpinBox in $Enemies/VBox.get_children():
		if spin_box.option == 0:
			continue
		var enemy: Monster = enemies[spin_box.option - 1].instantiate()
		Global.chosen_monsters.append(enemy)
	if Global.chosen_monsters.is_empty():
		Global.chosen_monsters.append(enemies[0].instantiate())
	
	Global.items = [
		dark_candy, dark_candy, dark_candy, dark_candy, dark_candy, dark_candy, dark_candy, dark_candy
	]
	Global.change_to_scene("res://scenes/battle/battle.tscn")

func _on_back_pressed() -> void:
	Sounds.play("snd_select")
	$Characters.visible = false
	$Enemies.visible = false
	$Equipment.visible = false
	$Main.visible = true
	do_focus_noise = false
	$Main/Start.grab_focus()
	do_focus_noise = true

func _on_characters_pressed() -> void:
	Sounds.play("snd_select")
	$Main.visible = false
	$Characters.visible = true
	do_focus_noise = false
	$Characters/VBox/Char1.grab_focus()
	await get_tree().process_frame
	$Heart.position = Vector2(90.0, $Characters/VBox/Char1.global_position.y + 48.0 / 2.0 + 2.0)
	do_focus_noise = true

func _on_enemies_pressed() -> void:
	Sounds.play("snd_select")
	$Main.visible = false
	$Enemies.visible = true
	do_focus_noise = false
	$Enemies/VBox/Enemy1.grab_focus()
	await get_tree().process_frame
	$Heart.position = Vector2(90.0, $Enemies/VBox/Enemy1.global_position.y + 48.0 / 2.0 + 2.0)
	do_focus_noise = true

func _on_equipment_pressed() -> void:
	Sounds.play("snd_select")
	$Main.visible = false
	$Equipment.visible = true
	do_focus_noise = false
	$Equipment/VBox/Weapon.grab_focus()
	await get_tree().process_frame
	$Heart.position = Vector2(90.0, $Equipment/VBox/Weapon.global_position.y + 48.0 / 2.0 + 2.0)
	do_focus_noise = true
