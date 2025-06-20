extends Node2D

enum CONTEXT {
	BATTLE, CHAR_MENU, MONSTER_SELECT, CHAR_SELECT, ITEM_SELECT, ACT_SELECT, MAGIC_SELECT, ACTION, WON
}

class Action:
	var what: int
	var to: int
	var specific: int

var context := CONTEXT.BATTLE:
	set(p_context):
		match context:
			CONTEXT.CHAR_MENU:
				char_menus[current_char].focused = false
			CONTEXT.MONSTER_SELECT:
				$MonsterSelect.focused = false
			CONTEXT.CHAR_SELECT:
				$CharSelect.focused = false
			CONTEXT.ITEM_SELECT:
				$ItemSelect.focused = false
			CONTEXT.ACT_SELECT:
				$ActSelect.focused = false
			CONTEXT.MAGIC_SELECT:
				$MagicSelect.focused = false
			CONTEXT.ACTION:
				for character: Character in Global.characters:
					if character.alive and !character.defending:
						character.idle()
			CONTEXT.BATTLE:
				for character: Character in Global.characters:
					if !character.alive:
						character.heal(ceili(character.max_hp * 0.13))
					if character.defending and character.alive:
						character.idle()
						character.defending = false
				for char_menu: CharMenu in char_menus:
					char_menu.deconfirm_action()
				Global.items.erase(null)
				$ItemSelect.reset_items()
				for item: Item in Global.items:
					$ItemSelect.add_item(item.name, item.short_description)
		context = p_context
		match context:
			CONTEXT.BATTLE:
				get_parent().start_attack()
			CONTEXT.CHAR_MENU:
				char_menus[current_char].activate()
				Global.characters[current_char].idle()
			CONTEXT.MONSTER_SELECT:
				$MonsterSelect.visible = true
				$MonsterSelect.focused = true
				$MonsterSelect.selected_item = 0
			CONTEXT.CHAR_SELECT:
				$CharSelect.visible = true
				$CharSelect.focused = true
				$CharSelect.selected_item = 0
			CONTEXT.ITEM_SELECT:
				$ItemSelect.visible = true
				$ItemSelect.focused = true
				$ItemSelect.selected_coords = Vector2.ZERO
			CONTEXT.ACT_SELECT:
				$ActSelect.reset_items()
				for act: Act in Global.characters[current_char].get_acts():
					$ActSelect.add_item(act.title)
				$ActSelect.visible = true
				$ActSelect.focused = true
				$ActSelect.selected_coords = Vector2.ZERO
			CONTEXT.MAGIC_SELECT:
				$MagicSelect.reset_items()
				for spell: Spell in Global.characters[current_char].get_spells():
					$MagicSelect.add_item(spell.title, spell.description, spell.tp_cost)
				$MagicSelect.visible = true
				$MagicSelect.focused = true
				$MagicSelect.selected_coords = Vector2.ZERO
			CONTEXT.ACTION:
				$TextBox.hide_text()
				for char_menu: CharMenu in char_menus:
					if char_menu.selected_item != Global.DEFEND:
						char_menu.deconfirm_action()
				current_char = -1
				do_next_action()

var char_menus: Array[CharMenu] = []
var current_char := 0

var actions: Array[Action] = []

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
	if Global.displaying_text and $TextBox.require_input:
		return
	if (event.is_action("confirm") or event.is_action("cancel")) and event.is_pressed():
		match context:
			CONTEXT.BATTLE:
				return
			CONTEXT.CHAR_MENU:
				if current_char == 0 and event.is_action("cancel"):
					return
				if event.is_action("cancel"):
					char_menus[current_char].deactivate()
					current_char -= 1
					char_menus[current_char].activate()
					char_menus[current_char].deconfirm_action()
					Global.characters[current_char].idle()
					return
				Sounds.play("snd_select")
				queue_character_action()
				return
			CONTEXT.MONSTER_SELECT:
				if event.is_action("cancel"):
					context = CONTEXT.CHAR_MENU
					return
				Sounds.play("snd_select")
				actions[current_char].to = $MonsterSelect.get_monster_id()
				if actions[current_char].what == Global.ACT and !char_menus[current_char].uses_magic:
					context = CONTEXT.ACT_SELECT
					return
				if actions[current_char].what == Global.SPARE:
					Global.characters[current_char].prep_spare()
					next_char()
					return
				Global.characters[current_char].prep_attack()
				next_char()
				return
			CONTEXT.CHAR_SELECT:
				if event.is_action("cancel"):
					context = CONTEXT.CHAR_MENU
					return
				Sounds.play("snd_select")
				actions[current_char].to = $CharSelect.selected_item
				Global.characters[current_char].prep_item()
				next_char()
				return
			CONTEXT.ACT_SELECT:
				if event.is_action("cancel"):
					context = CONTEXT.MONSTER_SELECT
					return
				Sounds.play("snd_select")
				actions[current_char].specific = $ActSelect.selected_item
				Global.characters[current_char].prep_act()
				next_char()
				return
			CONTEXT.MAGIC_SELECT:
				if event.is_action("cancel"):
					context = CONTEXT.CHAR_MENU
					return
				Sounds.play("snd_select")
				actions[current_char].specific = $MagicSelect.selected_item
				Global.characters[current_char].prep_act()
				next_char()
				return
			CONTEXT.ITEM_SELECT:
				if event.is_action("cancel"):
					context = CONTEXT.CHAR_MENU
					return
				Sounds.play("snd_select")
				actions[current_char].specific = $ItemSelect.selected_item
				context = CONTEXT.CHAR_SELECT
				return

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
			actions[current_char].what = Global.ITEM
			context = CONTEXT.ITEM_SELECT
		Global.SPARE:
			actions[current_char].what = Global.SPARE
			context = CONTEXT.MONSTER_SELECT
		Global.DEFEND:
			actions[current_char].what = Global.DEFEND
			Global.characters[current_char].defend()
			next_char()

func next_char() -> void:
	if context == CONTEXT.ACTION:
		for character: Character in Global.characters:
			if !character.alive:
				character.heal(ceili(character.max_hp * 0.13))
	
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
	match actions[current_char].what:
		Global.FIGHT:
			current_char += 1
			do_next_action()
			return
		Global.ACT:
			Global.characters[current_char].do_act(
				Global.monsters[actions[current_char].to], actions[current_char].specific
			)
			await Global.characters[current_char].act_finished
			current_char += 1
			do_next_action()
			return
		Global.ITEM:
			Global.characters[current_char].use_item(
				Global.characters[actions[current_char].to], actions[current_char].specific
			)
			await Global.characters[current_char].item_used
			current_char += 1
			do_next_action()
			return
		Global.SPARE:
			Global.characters[current_char].do_spare(
				Global.monsters[actions[current_char].to]
			)
			await Global.characters[current_char].spare_finished
			current_char += 1
			do_next_action()
			return
		Global.DEFEND:
			current_char += 1
			do_next_action()
			return

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
