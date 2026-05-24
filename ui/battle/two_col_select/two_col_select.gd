extends SelectMenu

@export var show_description := true
@export var show_tp := false

@onready var two_col_item_scene := preload("res://ui/battle/two_col_select/two_col_item/two_col_item.tscn")

func initialize_panels() -> void:
	$Description.visible = show_description
	$TP.visible = show_tp
	$AnimationPlayer.play("arrow_movement")
	super()

func set_selected_item(p_item: int) -> void:
	$Description.text = visible_items[p_item].description
	$TP.text = str(roundi(visible_items[p_item].tp)) + "%"
	$Clip/Items.position.y = 3.0
	$Arrows.visible = visible_items.size() > 6
	if $Arrows.visible:
		if p_item < 6:
			$Arrows/UpArrow.visible = false
			$Arrows/DownArrow.visible = true
		else:
			$Arrows/UpArrow.visible = true
			$Arrows/DownArrow.visible = false
			$Clip/Items.position.y -= 102.0

func add_item(p_name: String, p_description := "", p_tp := 0.0) -> void:
	var new_item: TwoColItem = two_col_item_scene.instantiate()
	new_item.initialize(p_name, p_description, p_tp)
	new_item.battle = battle
	$Clip/Items.add_child(new_item)
	items.append(new_item)
	visible_items.append(new_item)
	has_items = true

func add_items(p_names: Array[String], p_descriptions: Array[String]) -> void:
	for i: int in p_names.size():
		var new_item: TwoColItem = two_col_item_scene.instantiate()
		if p_descriptions.is_empty():
			new_item.initialize(p_names[i], "")
		else:
			new_item.initialize(p_names[i], p_descriptions[i])
		$Clip/Items.add_child(new_item)
		items.append(new_item)
		visible_items.append(new_item)
	if !p_names.is_empty():
		has_items = true

func show_item(p_index: int, p_show := true) -> void:
	var item := items[p_index]
	if item.visible and !p_show:
		item.visible = false
		item.set_select(false)
		visible_items.erase(item)
	elif !item.visible and p_show:
		item.visible = true
		visible_items.append(item)
		visible_items.sort_custom(custom_sort)
	has_items = !visible_items.is_empty()

func get_current_id() -> int:
	return items.find(visible_items[selected_item])

func custom_sort(a: TwoColItem, b: TwoColItem) -> bool:
	return items.find(a) < items.find(b)
