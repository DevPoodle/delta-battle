extends Node2D
class_name Battle

enum DefeatContext {
	FLEE, SPARED, SNOWGRAVED
}

signal killed_monster(monster: Monster, context: DefeatContext)
signal tp_changed

@onready var soul_cage: StaticBody2D = $SoulCage
@onready var tp_bar: Node2D = $TPBar

@export var monsters: Array[Monster] = []

var in_attack := false
var turn_timer := 0.0

var total_money := 0
var total_xp := 0
var money_multiplier := 0.0

static var tp_coefficient := 1
var tp := 0.0:
	set(p_tp):
		tp = minf(p_tp, 250.0)
		tp_changed.emit()

func _ready() -> void:
	Global.current_battle = self
	if monsters.is_empty():
		monsters = Global.chosen_monsters
	tp_changed.connect(tp_bar.set_tp)
	for item in Global.items:
		if item.usePredicate.item == null:
			item.usePredicate.item = item
	set_positions($Characters, Global.characters, Vector2(108.0, 0.0))
	set_positions($Monsters, monsters, Vector2(640.0 - 108.0, 0.0))
	Global.display_text.emit(Global.get_opening_line(), false)
	killed_monster.connect(monster_killed)
	
	for monster: Monster in monsters:
		total_money += monster.money_dropped
		total_xp += monster.xp_bled
		money_multiplier += monster.get_value_from_stat(AbstractFighter.Stats.MONEY_MULTIPLIER)
	
	for player: Character in Global.characters:
		money_multiplier += player.get_value_from_stat(AbstractFighter.Stats.MONEY_MULTIPLIER)
	
	tp = 0.0
	
	Sounds.play("snd_impact", 0.7)
	Sounds.play("snd_weaponpull_fast", 0.8)
	Sounds.set_music("battle", 0.7)

func tp_percent_to_absolute(p_percent: float) -> float:
	return p_percent / 100.0 * 250.0

func _process(p_delta: float) -> void:
	if in_attack:
		turn_timer -= p_delta
		if turn_timer <= 0.0:
			in_attack = false
			end_attack()

func set_positions(p_parent: Node, p_nodes: Array, p_offset := Vector2.ZERO):
	var size := p_nodes.size()
	if size == 1:
		var node: Node2D = p_nodes[0]
		node.battle = self
		p_parent.add_child(node)
		node.position = Vector2(0.0, Global.CENTER.y) + p_offset
	elif size == 2:
		var node_1: Node2D = p_nodes[0]
		var node_2: Node2D = p_nodes[1]
		node_1.battle = self
		node_2.battle = self
		p_parent.add_child(node_1)
		p_parent.add_child(node_2)
		node_1.position = Vector2(0.0, Global.CENTER.y - 48.0) + p_offset
		node_2.position = Vector2(0.0, Global.CENTER.y + 96.0 - 48.0) + p_offset
	else:
		for i: int in size:
			var node: Node2D = p_nodes[i]
			node.battle = self
			p_parent.add_child(node)
			node.position.x = 0.0
			node.position.y = Global.CENTER.y - 96.0 + 2.0 * 96.0 * i / (size - 1)
			node.position += p_offset

func start_attack() -> void:
	play_heart_animation()
	$Soul.position = ($Characters.get_child(0) as Character).position
	$Soul.visible = true
	var tween := get_tree().create_tween()
	tween.tween_property($Soul, "position", Global.CENTER, 0.25)
	$SoulCage.expand()
	await $SoulCage.finished_animation
	$Soul.active = true
	for beh in $Soul.behaviors:
		beh.turn_start()

	
	var alive_monsters: Array[Monster] = []
	for monster: Monster in monsters:
		if monster != null:
			alive_monsters.append(monster)
	if alive_monsters.is_empty():
		return
	var monster: Monster = alive_monsters.pick_random()
	turn_timer = monster.start_attack()
	in_attack = true

func end_attack(p_continue_battle := true) -> void:
	for monster: Monster in monsters:
		if monster != null:
			monster.end_attack()
	$Soul.active = false
	for beh in $Soul.behaviors:
		beh.turn_end()
	var tween := get_tree().create_tween()
	tween.tween_property($Soul, "position", ($Characters.get_child(0) as Character).position, 0.25)
	tween.finished.connect(play_heart_animation)
	$SoulCage.contract()
	await $SoulCage.finished_animation
	if p_continue_battle:
		$BottomPanel.current_char = -1
		for char_menu: CharMenu in $BottomPanel.char_menus:
			char_menu.selected_item = 0
		$BottomPanel.start_turn()
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

func monster_killed(p_monster: Monster, p_context: DefeatContext) -> void:
	if p_context != Battle.DefeatContext.SNOWGRAVED:
		total_xp -= p_monster.xp_bled
	
	var monsters_dead := true
	for monster: Monster in monsters:
		if monster != null:
			monsters_dead = false
			break
	# End battle if all monsters are dead.
	if monsters_dead:
		$BottomPanel.continue_battle = false
		$BottomPanel/AttackTiming.focused = false
		for character: Character in Global.characters:
			character.do_animation(Character.Animations.IDLE)
		var money : int = floori((total_money * Global.chapter / 4) * money_multiplier)
		Global.display_text.emit("  * You won!\n[color=#000]----[/color]Got %d EXP and %dD$." % [total_xp, money], true)
		await Global.text_finished
		Global.change_to_scene("res://scenes/menus/win_screen/win_screen.tscn")

func delete_monster(p_monster: Monster, p_context: DefeatContext) -> void:
	var monster_index := monsters.find(p_monster)
	if monster_index != -1:
		monsters[monster_index] = null
		killed_monster.emit(p_monster, p_context)
