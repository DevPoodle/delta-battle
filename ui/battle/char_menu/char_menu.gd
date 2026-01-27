extends Control
class_name CharMenu

const PURPLE := Color("#332033")

var main_color := Color.WHITE:
	set(p_main_color):
		main_color = p_main_color
		var health_box: StyleBoxFlat = $Stats/HealthBar.get_theme_stylebox("fill")
		health_box.bg_color = main_color
var current_hp := 100:
	set(p_current_hp):
		current_hp = p_current_hp
		$Stats/HealthBar.value = maxi(0, current_hp)
		$Stats/CurrentHP.text = str(current_hp)
		update_hp_color()
var max_hp := 100:
	set(p_max_hp):
		max_hp = p_max_hp
		$Stats/HealthBar.max_value = maxi(1, max_hp)
		$Stats/MaxHP.text = str(max_hp)
		update_hp_color()
var can_spare := false:
	set(p_can_spare):
		can_spare = p_can_spare
		actions[Global.SPARE].flashing = can_spare
var uses_magic := false:
	set(p_uses_magic):
		uses_magic = p_uses_magic
		actions[Global.ACT] = $Actions/Magic if uses_magic else $Actions/Act
		$Actions/Magic.visible = uses_magic
		$Actions/Act.visible = !uses_magic

var activated := false:
	set(p_activated):
		activated = p_activated
		$Actions/BGLineAnimation.visible = activated
		for action: CharMenuButton in actions:
			action.activated = activated
var focused := false:
	set(p_focused):
		focused = p_focused
		selected_item = selected_item
		can_spare = false
		for monster: Monster in Global.monsters:
			if monster != null and monster.mercy_percent >= 1.0:
				can_spare = true
				return
var selected_item := 0:
	set(p_selected_item):
		actions[selected_item].selected = false
		selected_item = p_selected_item
		actions[selected_item].selected = true

@onready var style_box: StyleBoxFlat = $Stats.get_theme_stylebox("panel")
@onready var actions: Array[CharMenuButton] = [
	$Actions/Attack,
	$Actions/Act,
	$Actions/Item,
	$Actions/Spare,
	$Actions/Defend
]

func _unhandled_key_input(p_event: InputEvent) -> void:
	if focused and p_event is InputEventKey and p_event.is_pressed():
		if p_event.is_action("left"):
			var prev_item := selected_item
			selected_item = wrapi(selected_item - 1, 0, 5)
			if selected_item != prev_item:
				Sounds.play("snd_menumove")
		elif p_event.is_action("right"):
			var prev_item := selected_item
			selected_item =  wrapi(selected_item + 1, 0, 5)
			if selected_item != prev_item:
				Sounds.play("snd_menumove")

func update_hp_color() -> void:
	if current_hp < 0.2 * $Stats/HealthBar.max_value:
		($Stats/CurrentHP.label_settings as LabelSettings).font_color = Global.YELLOW
		($Stats/MaxHP.label_settings as LabelSettings).font_color = Global.YELLOW
	else:
		($Stats/CurrentHP.label_settings as LabelSettings).font_color = Color.WHITE
		($Stats/MaxHP.label_settings as LabelSettings).font_color = Color.WHITE

func set_current_health(p_current_health: int) -> void:
	current_hp = p_current_health

func set_from_character(character: Character) -> void:
	$Stats/Name.text = character.title
	current_hp = character.current_hp
	max_hp = character.get_max_hp()
	main_color = character.main_color
	$Stats/Icon.texture = character.icon
	$Stats/ActionIcon.modulate = character.icon_color
	$Actions/BGLineAnimation.modulate = character.main_color
	character.health_changed.connect(set_current_health)
	
	await ready
	uses_magic = character.uses_magic

func activate():
	$Cover1.visible = false
	$Cover2.visible = false
	style_box.border_color = main_color
	activated = true
	focused = true
	
	if $Stats.position.y == -32.0:
		return
	
	$Stats.position.y = -16.0
	var tween := get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($Stats, "position", Vector2($Stats.position.x, -32.0), 1.0 / 6.0)

func deactivate():
	style_box.border_color = PURPLE
	var tween := get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($Stats, "position", Vector2($Stats.position.x, 0.0), 1.0 / 10.0)
	$Cover1.visible = true
	$Cover2.visible = true
	
	activated = false
	focused = false

func confirm_action(action: int) -> void:
	$Stats/Icon.visible = false
	$Stats/ActionIcon.visible = true
	if action == 1:
		$Stats/ActionIcon.frame = action + int(uses_magic)
	else:
		$Stats/ActionIcon.frame = action + int(action > 1)

func deconfirm_action() -> void:
	$Stats/Icon.visible = true
	$Stats/ActionIcon.visible = false
