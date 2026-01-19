extends Node2D

enum CONTEXT {
	BATTLE, CHAR_MENU, MONSTER_SELECT, CHAR_SELECT, ITEM_SELECT, ACT_SELECT, MAGIC_SELECT, ACTION, WON
}

class Action:
	var what: int
	var to: int
	var specific: int

@onready var menus: Dictionary[CONTEXT, SelectMenu] = {
	CONTEXT.MONSTER_SELECT: $MonsterSelect, CONTEXT.CHAR_SELECT: $CharSelect, CONTEXT.ITEM_SELECT: $ItemSelect,
	CONTEXT.ACT_SELECT: $ActSelect, CONTEXT.MAGIC_SELECT: $MagicSelect
}

var context := CONTEXT.BATTLE:
	set(p_context):
		if CONTEXT.MONSTER_SELECT <= context and context <= CONTEXT.MAGIC_SELECT:
			menus[context].focused = false
		match context:
			CONTEXT.CHAR_MENU:
				char_menus[current_char].focused = false
			CONTEXT.ACTION:
				for character: Character in Global.characters:
					if character.alive and !character.defending:
						character.do_animation(Character.Animations.IDLE)
			#CONTEXT.BATTLE:
		context = p_context
		match context:
			CONTEXT.BATTLE:
				get_parent().start_attack()
			CONTEXT.CHAR_MENU:
				char_menus[current_char].activate()
				Global.characters[current_char].do_animation(Character.Animations.IDLE)
			CONTEXT.ACT_SELECT:
				$ActSelect.clear_items()
				var acts := Global.characters[current_char].get_acts(Global.monsters[actions[current_char].to])
				for act: Act in acts:
					$ActSelect.add_item(act.title)
			CONTEXT.MAGIC_SELECT:
				$MagicSelect.clear_items()
				for spell: Spell in Global.characters[current_char].get_spells():
					$MagicSelect.add_item(spell.title, spell.description, spell.tp_percent_cost)
			CONTEXT.ACTION:
				$TextBox.hide_text()
				for char_menu: CharMenu in char_menus:
					if char_menu.selected_item != Global.DEFEND:
						char_menu.deconfirm_action()
				current_char = -1
				do_next_action()
		if CONTEXT.MONSTER_SELECT <= context and context <= CONTEXT.MAGIC_SELECT:
			menus[context].visible = true
			menus[context].selected_coords = Vector2.ZERO
			menus[context].focused = true

var char_menus: Array[CharMenu] = []
var current_char := 0
var actions: Array[Action] = []
var continue_battle := true

func _ready() -> void:
	for character: Character in Global.characters:
		var char_menu := preload("res://ui/battle/char_menu/char_menu.tscn").instantiate()
		char_menu.set_from_character(character)
		$Characters.add_child(char_menu)
		char_menus.append(char_menu)
		actions.append(Action.new())
	for item: Item in Global.items:
		$ItemSelect.add_item(item.name, item.short_description)
	context = CONTEXT.CHAR_MENU

func _unhandled_key_input(event: InputEvent) -> void:
	if (Global.displaying_text and $TextBox.require_input) or context == CONTEXT.BATTLE or !continue_battle:
		return
	if (event.is_action("confirm") or event.is_action("cancel")) and event.is_pressed():
		if event.is_action("cancel"):
			undo_input()
			return
		
		Sounds.play("snd_select")
		if CONTEXT.MONSTER_SELECT <= context:
			if context <= CONTEXT.CHAR_SELECT:
				actions[current_char].to = menus[context].get_current_id()
			elif context <= CONTEXT.MAGIC_SELECT:
				actions[current_char].specific = menus[context].get_current_id()
		
		match context:
			CONTEXT.CHAR_MENU:
				queue_character_action()
				return
			CONTEXT.MONSTER_SELECT:
				if actions[current_char].what == Global.ACT:
					if !char_menus[current_char].uses_magic:
						context = CONTEXT.ACT_SELECT
						return
					else:
						next_char()
						return
				if actions[current_char].what == Global.SPARE:
					Global.characters[current_char].prep_spare()
					next_char()
					return
				Global.characters[current_char].prep_attack()
				next_char()
				return
			CONTEXT.CHAR_SELECT:
				if actions[current_char].what != Global.ACT or !char_menus[current_char].uses_magic:
					Global.characters[current_char].prep_item()
				next_char()
				return
			CONTEXT.ACT_SELECT:
				Global.characters[current_char].prep_act()
				next_char()
				return
			CONTEXT.MAGIC_SELECT:
				var spells := Global.characters[current_char].get_spells()
				var spell := spells[menus[CONTEXT.MAGIC_SELECT].get_current_id()]
				var tp_cost := Global.tp_percent_to_absolute(spell.tp_percent_cost)
				
				if tp_cost > Global.tp:
					return
				
				Global.tp -= tp_cost
				context = CONTEXT.CHAR_SELECT if spell.target == 0 else CONTEXT.MONSTER_SELECT
				Global.characters[current_char].prep_act()
				return
			CONTEXT.ITEM_SELECT:
				context = CONTEXT.CHAR_SELECT
				$ItemSelect.show_item($ItemSelect.get_current_id(), false)
				return

func undo_input() -> void:
	match context:
		CONTEXT.CHAR_MENU:
			if current_char == 0:
				return
			char_menus[current_char].deactivate()
			current_char -= 1
			if actions[current_char].what == Global.ITEM:
				$ItemSelect.show_item(actions[current_char].specific, true)
			elif actions[current_char].what == Global.ACT:
				if Global.characters[current_char].uses_magic:
					var spells := Global.characters[current_char].get_spells()
					var spell := spells[menus[CONTEXT.MAGIC_SELECT].get_current_id()]
					var tp_cost := Global.tp_percent_to_absolute(spell.tp_percent_cost)
					Global.tp += tp_cost
			elif actions[current_char].what == Global.DEFEND:
				Global.tp -= 40
			char_menus[current_char].activate()
			char_menus[current_char].deconfirm_action()
			Global.characters[current_char].do_animation(Character.Animations.IDLE)
			return
		CONTEXT.CHAR_SELECT, CONTEXT.MONSTER_SELECT:
			if actions[current_char].what == Global.ITEM:
				$ItemSelect.show_item(actions[current_char].specific, true)
				context = CONTEXT.CHAR_MENU
				return
			if actions[current_char].what == Global.ACT and char_menus[current_char].uses_magic:
				var spells := Global.characters[current_char].get_spells()
				var spell := spells[menus[CONTEXT.MAGIC_SELECT].get_current_id()]
				var tp_cost := Global.tp_percent_to_absolute(spell.tp_percent_cost)
				
				Global.tp += tp_cost
				context = CONTEXT.MAGIC_SELECT
				return
		CONTEXT.ACT_SELECT:
			context = CONTEXT.MONSTER_SELECT
			return
	if (CONTEXT.MONSTER_SELECT <= context and context <= CONTEXT.ITEM_SELECT) or context == CONTEXT.MAGIC_SELECT:
		context = CONTEXT.CHAR_MENU

func queue_character_action() -> void:
	match char_menus[current_char].selected_item:
		Global.FIGHT:
			actions[current_char].what = Global.FIGHT
			context = CONTEXT.MONSTER_SELECT
		Global.ACT:
			actions[current_char].what = Global.ACT
			if !char_menus[current_char].uses_magic:
				context = CONTEXT.MONSTER_SELECT
			else:
				context = CONTEXT.MAGIC_SELECT
		Global.ITEM:
			if $ItemSelect.has_items:
				actions[current_char].what = Global.ITEM
				context = CONTEXT.ITEM_SELECT
		Global.SPARE:
			actions[current_char].what = Global.SPARE
			context = CONTEXT.MONSTER_SELECT
		Global.DEFEND:
			actions[current_char].what = Global.DEFEND
			Global.characters[current_char].defend()
			Global.tp += 40 * Global.tp_coefficient
			next_char()

func start_turn() -> void:
	for character: Character in Global.characters:
		if !character.alive:
			character.heal(ceili(character.max_hp * character.HP_FRACTION_DOWNED_REGEN))
		if character.defending and character.alive:
			character.do_animation(Character.Animations.IDLE)
			character.defending = false
	for char_menu: CharMenu in char_menus:
		char_menu.deconfirm_action()
	var i := 0
	while i < Global.items.size():
		if Global.items[i] == null:
			Global.items.remove_at(i)
		else:
			i += 1
	$ItemSelect.clear_items()
	for item: Item in Global.items:
		$ItemSelect.add_item(item.name, item.short_description)
	next_char()

func next_char() -> void:
	if context == CONTEXT.ACTION:
		for character: Character in Global.characters:
			if !character.alive:
				character.heal(ceili(character.max_hp * character.HP_FRACTION_DOWNED_REGEN))
	
	var next_character := current_char + 1
	var valid_char := false
	while next_character < char_menus.size():
		if Global.characters[next_character].alive:
			valid_char = true
			break
		next_character += 1
	
	if !valid_char:
		char_menus[current_char].confirm_action(actions[current_char].what)
		char_menus[current_char].deactivate()
		context = CONTEXT.ACTION
	else:
		if current_char != -1:
			char_menus[current_char].deactivate()
			char_menus[current_char].confirm_action(actions[current_char].what)
		current_char = next_character
		context = CONTEXT.CHAR_MENU

func do_next_action() -> void:
	if !continue_battle:
		return
	if current_char == -1:
		var fighting_characters := PackedInt32Array()
		for i: int in actions.size():
			var action := actions[i]
			if action.what == Global.FIGHT and Global.characters[i].alive:
				fighting_characters.append(i)
				$AttackTiming.set_as_attacking(i, true)
			else:
				$AttackTiming.set_as_attacking(i, false)
		current_char = 0
		if !fighting_characters.is_empty():
			$AttackTiming.focused = true
		else:
			do_next_action()
		return
	if current_char >= char_menus.size():
		current_char = 0
		context = CONTEXT.BATTLE
		return
	if !Global.characters[current_char].alive:
		current_char += 1
		do_next_action()
		return
	var action := actions[current_char]
	var does_magic := Global.characters[current_char].uses_magic
	var to := action.to
	if action.what == Global.ACT or action.what == Global.SPARE:
		var checked := 1
		while Global.monsters[to] == null and checked <= Global.monsters.size():
			to = (to + 1) % Global.monsters.size()
			checked += 1
	match action.what:
		Global.ACT:
			if !does_magic:
				Global.characters[current_char].do_act(
					Global.monsters[to], action.specific
				)
				await Global.characters[current_char].act_finished
			else:
				var spell := Global.characters[current_char].get_spells()[action.specific]
				var entity := Global.characters[to] as Node2D if spell.target == 0 else Global.monsters[to] as Node2D
				Global.characters[current_char].do_spell(
					entity, spell
				)
				await Global.characters[current_char].spell_finished
		Global.ITEM:
			Global.characters[current_char].use_item(
				Global.characters[to], action.specific
			)
			await Global.characters[current_char].item_used
		Global.SPARE:
			Global.characters[current_char].do_spare(
				Global.monsters[to]
			)
			await Global.characters[current_char].spare_finished
	current_char += 1
	do_next_action()

func do_attack(p_char_id: int, p_damage: int) -> void:
	var monster := Global.monsters[actions[p_char_id].to]
	if monster == null:
		for i: int in Global.monsters.size():
			if Global.monsters[i] != null:
				monster = Global.monsters[i]
				break
		if monster == null:
			do_next_action()
			return
	var character := Global.characters[p_char_id]
	character.do_attack(monster, p_damage)
