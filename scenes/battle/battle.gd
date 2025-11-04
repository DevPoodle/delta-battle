extends Node2D

var in_attack := false
var turn_timer := 0.0

var total_money : int = 0
var total_xp : int = 0

func _ready() -> void:
	set_positions($Characters, Global.characters, Vector2(108.0, 0.0))
	set_positions($Monsters, Global.monsters, Vector2(640.0 - 108.0, 0.0))
	Global.display_text.emit(Global.get_opening_line(), false)
	Global.monster_killed.connect(monster_killed)
	
	for i in Global.monsters:
		total_money += i.money_dropped
		total_xp += i.xp_bled
	
	Sounds.play("snd_impact", 0.7)
	Sounds.play("snd_weaponpull_fast", 0.8)
	Sounds.set_music("battle", 0.7)

func _process(delta: float) -> void:
	if in_attack:
		turn_timer -= delta
		if turn_timer <= 0.0:
			in_attack = false
			end_attack()

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
	if alive_monsters.is_empty():
		return
	var monster: Monster = alive_monsters.pick_random()
	turn_timer = monster.start_attack()
	in_attack = true

func end_attack(p_continue_battle := true) -> void:
	for monster: Monster in Global.monsters:
		if monster != null:
			monster.end_attack()
	
	$Soul.active = false
	var tween := get_tree().create_tween()
	tween.tween_property($Soul, "position", ($Characters.get_child(0) as Character).position, 0.25)
	tween.finished.connect(play_heart_animation)
	$SoulCage.contract()
	await $SoulCage.finished_animation
	if p_continue_battle:
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
		Global.change_to_scene("res://scenes/menus/lost_screen/lost_screen.tscn")
		Sounds.play("snd_break2", 0.6)

func monster_killed(monsterThatLeft : Monster, context : Global.DefeatContext) -> void:
	if context != Global.DefeatContext.SNOWGRAVED:
		total_xp -= monsterThatLeft.xp_bled
	
	var monsters_dead := true
	for monster: Monster in Global.monsters:
		if monster != null:
			monsters_dead = false
			break
	if monsters_dead:
		$BottomPanel.continue_battle = false
		$BottomPanel/AttackTiming.focused = false
		for character: Character in Global.characters:
			character.do_animation(Character.Animations.IDLE)
		Global.display_text.emit("  * You won!\n[color=#000]----[/color]Got " + str(total_xp) + " EXP and " + str(calculate_money()) + "D$.", true)
		await Global.text_finished
		Global.change_to_scene("res://scenes/menus/win_screen/win_screen.tscn")

func calculate_money() -> int:
	@warning_ignore("integer_division")
	return (total_money * Global.chapter) / 4
