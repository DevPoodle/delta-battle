extends Node

enum {
	FIGHT, ACT, ITEM, SPARE, DEFEND
}

enum DefeatContext {
	FLEE, SPARED, SNOWGRAVED
}

const YELLOW := Color("#ffff00")
const GREEN := Color("#00ff00")
const CENTER := Vector2(308.0, 171.0)
var tp := 0.0:
	set(p_tp):
		tp = minf(p_tp, 250.0)
		tp_changed.emit()

signal tp_changed
signal monster_killed(monster : Monster, context : DefeatContext)
signal display_text(p_text: String, p_requires_input: bool)
signal text_finished

var tp_coefficient := 1
var displaying_text := false
var characters: Array[Character] = []
var monsters: Array[Monster] = []
var items: Array[Item] = []

#This is just here to make sure the calculation works.
#Set this to whatever you want to get an accurate result.
var chapter : int = 2

func tp_percent_to_absolute(p_percent: float) -> float:
	return p_percent / 100.0 * 250.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.is_action("toggle_fullscreen"):
			if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			else:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func get_opening_line() -> String:
	var lines := PackedStringArray()
	
	for monster: Monster in monsters:
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
	
	for monster: Monster in monsters:
		if monster == null:
			continue
		var line := monster.get_idle_line()
		if line != "":
			lines.append(monster.get_idle_line())
	
	if lines.is_empty():
		if Global.monsters.size() == 1:
			return "  * The battle goes on..."
	return lines[randi_range(0, lines.size() - 1)]

func delete_monster(p_monster: Monster, context : DefeatContext) -> void:
	var monster_index := monsters.find(p_monster)
	if monster_index != -1:
		monsters[monster_index] = null
	monster_killed.emit(p_monster, context)

func delete_item(p_item: int) -> void:
	items[p_item] = null

func change_to_scene(scene_path: String, fade := true) -> void:
	if fade:
		PostProcessing.fade_out()
		get_tree().paused = true
		await PostProcessing.fade_finished
		get_tree().change_scene_to_file(scene_path)
		PostProcessing.fade_in()
		await PostProcessing.fade_finished
		get_tree().paused = false
	else:
		get_tree().change_scene_to_file(scene_path)

func wait_time(time: float) -> Signal:
	return get_tree().create_timer(time).timeout
