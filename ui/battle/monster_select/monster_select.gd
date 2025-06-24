extends SelectMenu

func set_selected_item(p_item: int) -> void:
	if selected_item < items.size() and items[selected_item]:
		Global.monsters[items[selected_item].monster_id].set_selected(false)
	Global.monsters[items[p_item].monster_id].set_selected(true and focused)

func get_current_id() -> int:
	return items[selected_item].monster_id

func initialize_panels() -> void:
	if !Global.monster_killed.is_connected(initialize_panels):
		Global.monster_killed.connect(initialize_panels)
	
	clear_items()
	for monster: Monster in Global.monsters:
		if monster == null:
			continue
		var monster_panel := preload("res://ui/battle/monster_select/monster_panel/monster_panel.tscn").instantiate()
		monster_panel.set_from_monster(monster)
		$Monsters.add_child(monster_panel)
		items.append(monster_panel)
	visible_items = items
	super()
