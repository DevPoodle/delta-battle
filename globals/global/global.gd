extends Node

enum {
	FIGHT, ACT, ITEM, SPARE, DEFEND
}



const YELLOW := Color("#ffff00")
const GREEN := Color("#00ff00")
const CENTER := Vector2(308.0, 171.0)

signal display_text(p_text: String, p_requires_input: bool)
signal text_finished

var displaying_text := false
var characters: Array[Character] = []
var chosen_monsters : Array[Monster] = []
var items: Array[Item] = []
var soulState : SoulState = SoulState.new()

var current_battle : Battle

# The current chapter number affects how much money is earned from a battle.
var chapter := 2

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(p_event: InputEvent) -> void:
	if p_event is InputEventKey and p_event.is_pressed():
		if p_event.is_action("toggle_fullscreen"):
			if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			else:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func get_opening_line() -> String:
	var lines := PackedStringArray()
	
	for monster: Monster in current_battle.monsters:
		var line := monster.get_opening_line()
		if line != "":
			lines.append(monster.get_opening_line())
	
	if lines.is_empty():
		if Global.monsters.size() == 1:
			return "  * You encountered a monster!"
		return "  * You encountered some monsters!"
	return lines[randi_range(0, lines.size() - 1)]

func get_idle_line() -> String:
	var lines := PackedStringArray()
	
	for monster: Monster in current_battle.monsters:
		if monster == null:
			continue
		var line := monster.get_idle_line()
		if line != "":
			lines.append(monster.get_idle_line())
	
	if lines.is_empty():
		if current_battle.monsters.size() == 1:
			return "  * The battle goes on..."
	return lines[randi_range(0, lines.size() - 1)]

func delete_item(p_item: int) -> void:
	items.pop_at(p_item).queue_free()
	items[p_item] = null

func change_to_scene(p_scene_path: String, p_fade := true) -> void:
	if p_fade:
		PostProcessing.fade_out()
		get_tree().paused = true
		await PostProcessing.fade_finished
		get_tree().change_scene_to_file(p_scene_path)
		PostProcessing.fade_in()
		await PostProcessing.fade_finished
		get_tree().paused = false
	else:
		get_tree().change_scene_to_file(p_scene_path)

func wait_time(p_time: float) -> Signal:
	return get_tree().create_timer(p_time).timeout

func set_heart_state(type : SoulType, dir : Direction = null) -> void:
	if (type == soulState.type && dir == soulState.direction):
		return
	soulState.set_type(type, false)
	if dir != null:
		soulState.set_rotation(dir, false)
	else:
		soulState.set_rotation(type.get_default_direction(), false)
	soulState.emit_changed()


# Handles how the heart looks in menus.
class SoulState extends Resource:
	@export var type : SoulType = SoulType.RED
	@export var direction : Direction = Direction.SOUTH
	
	func set_type(new_type : SoulType, should_emit_signal : bool = true) -> SoulState:
		if type == new_type:
			return
		type = new_type
		if should_emit_signal:
			emit_changed()
		return self
	
	func set_rotation(dir : Direction, should_emit_signal : bool = true) -> SoulState:
		if dir == direction:
			return
		direction = dir
		if should_emit_signal:
			emit_changed()
		return self
	
	func reset_type() -> SoulState:
		set_type(SoulType.RED)
		return self
	
	func reset_rotation() -> SoulState:
		if type.is_monster_soul:
			set_rotation(Direction.NORTH)
		else:
			set_rotation(Direction.SOUTH)
		return self
	
	func reset_properties() -> SoulState:
		reset_type()
		reset_rotation()
		return self
