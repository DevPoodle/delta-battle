extends Node2D

func _ready() -> void:
	set_positions($Characters, Global.characters, Vector2(108.0, 0.0))
	set_positions($Monsters, Global.monsters, Vector2(640.0 - 108.0, 0.0))
	Global.display_text.emit(Global.get_opening_line(), false)

func set_positions(parent: Node, nodes: Array, offset := Vector2.ZERO):
	var size := nodes.size()
	if size == 1:
		var node: Node2D = nodes[0]
		parent.add_child(node)
		node.position = Vector2(0.0, Global.CENTER.y) + offset
	elif size == 2:
		var node_1: Node2D = nodes[0]
		var node_2: Node2D = nodes[1]
		parent.add_child(node_1)
		parent.add_child(node_2)
		node_1.position = Vector2(0.0, Global.CENTER.y - 48.0) + offset
		node_2.position = Vector2(0.0, Global.CENTER.y + 96.0 - 48.0) + offset
	else:
		for i: int in size:
			var node: Node2D = nodes[i]
			parent.add_child(node)
			node.position.x = 0.0
			node.position.y = Global.CENTER.y - 96.0 + 2.0 * 96.0 * i / (size - 1)
			node.position += offset

func start_attack() -> void:
	play_heart_animation()
	$Soul.position = ($Characters.get_child(0) as Character).position
	$Soul.visible = true
	var tween := get_tree().create_tween()
	tween.tween_property($Soul, "position", Global.CENTER, 0.25)
	$SoulCage.expand()
	await $SoulCage.finished_animation
	$Soul.active = true
	
	var alive_monsters: Array[Monster] = []
	for monster: Monster in Global.monsters:
		if monster != null:
			alive_monsters.append(monster)
	var monster: Monster = alive_monsters.pick_random()
	monster.do_attack()
	await monster.attack_finished
	end_attack()
	
func end_attack() -> void:
	$Soul.active = false
	var tween := get_tree().create_tween()
	tween.tween_property($Soul, "position", ($Characters.get_child(0) as Character).position, 0.25)
	tween.finished.connect(play_heart_animation)
	$SoulCage.contract()
	await $SoulCage.finished_animation
	$BottomPanel.current_char = -1
	for char_menu: CharMenu in $BottomPanel.char_menus:
		char_menu.selected_item = 0
	$BottomPanel.next_char()
	Global.display_text.emit(Global.get_idle_line(), false)

func play_heart_animation() -> void:
	$Soul.visible = false

func hurt(p_damage: int) -> void:
	var alive_characters: Array[Character] = []
	for character: Character in Global.characters:
		if character.alive:
			alive_characters.append(character)
	if alive_characters.is_empty():
		return
	var character: Character = alive_characters.pick_random()
	character.hurt(p_damage)
	if alive_characters.size() == 1 and !character.alive:
		await character.faint_finished
		Global.change_to_scene("res://scenes/lost_screen/lost_screen.tscn")
