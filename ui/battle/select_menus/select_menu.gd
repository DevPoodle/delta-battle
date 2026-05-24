extends Node2D
class_name SelectMenu

@export var battle : Battle
@export_range(1, 3) var columns := 1

var focused := false:
	set(p_focused):
		focused = p_focused
		visible = focused
		for item: SelectPanel in items:
			item.set_select(false)
		selected_item = selected_item

var selected_item := 0:
	set(p_selected_item):
		if items.is_empty():
			initialize_panels()
			return
		if 0 <= selected_item and selected_item < visible_items.size():
			visible_items[selected_item].set_select(false)
		set_selected_item(clampi(p_selected_item, 0, visible_items.size() - 1))
		selected_item = clampi(p_selected_item, 0, visible_items.size() - 1)
		visible_items[selected_item].set_select(true)

var selected_coords := Vector2i.ZERO:
	set(p_selected_coords):
		selected_coords = Vector2(p_selected_coords.x % columns, p_selected_coords.y)
		selected_item = selected_coords.y * columns + selected_coords.x

var items: Array[SelectPanel] = []
var visible_items: Array[SelectPanel] = []
var has_items := false

func set_selected_item(_p_item: int) -> void:
	pass

func get_current_id() -> int:
	return 0

func _ready() -> void:
	initialize_panels()

func clear_items() -> void:
	for item: SelectPanel in items:
		item.queue_free()
	visible_items.clear()
	items.clear()
	has_items = false

func initialize_panels() -> void:
	for item: SelectPanel in items:
		item.set_select(false)
		item.battle = battle
	if !items.is_empty():
		selected_item = 0

func _unhandled_key_input(p_event: InputEvent) -> void:
	if focused and p_event is InputEventKey and p_event.is_pressed():
		var prev_item := selected_item
		if p_event.is_action("up"):
			selected_coords.y = maxi(0, selected_coords.y - 1)
		elif p_event.is_action("down"):
			if selected_item >= visible_items.size() - columns:
				return
			selected_coords.y = selected_coords.y + 1
		elif p_event.is_action("left") and columns > 1:
			if visible_items.size() % columns == 1 and selected_item == visible_items.size() - 1:
				return
			selected_coords.x = wrapi(selected_coords.x - 1, 0, columns)
		elif p_event.is_action("right") and columns > 1:
			if visible_items.size() % columns == 1 and selected_item == visible_items.size() - 1:
				return
			selected_coords.x = wrapi(selected_coords.x + 1, 0, columns)
		if prev_item != selected_item:
			Sounds.play("snd_menumove")
