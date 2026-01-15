extends Control
class_name CharTiming

var char_id := 0
var active := false
var frame := 0
@onready var indicator: Panel = $AttackIndicator

func set_from_character(p_character: Character) -> void:
	$Icon.texture = p_character.icon
	$PerfectHit.modulate = p_character.icon_color
	$HitRegion.modulate = p_character.main_color.darkened(0.5)
	char_id = Global.characters.find(p_character)

func set_active(p_active: bool) -> void:
	active = p_active
	for child: CanvasItem in get_children():
		child.visible = active
	indicator.position.x = 410.0 + 96.0 * randi_range(-1, 1)
	frame = 0

func _process(delta: float) -> void:
	if !active:
		return
	if frame % 2 == 0 and indicator.visible:
		create_shadow()
	for shadow: Panel in $IndicatorShadows.get_children():
		shadow.modulate.a -= 1.2 * delta
		if shadow.modulate.a <= 0.0:
			shadow.queue_free()
	frame += 1
	if indicator.visible:
		indicator.position.x -= 8.0 * 30.0 * delta
		if indicator.position.x < 64.0:
			create_shadow()
			indicator.visible = false
			get_parent().get_parent().hit()

func create_shadow() -> void:
	var new_shadow: Panel = indicator.duplicate()
	new_shadow.modulate.a = 0.4
	$IndicatorShadows.add_child(new_shadow)

func hit() -> int:
	var perfect_hit := absf(indicator.position.x - $PerfectHit.position.x) < 2.0
	indicator.visible = false
	$Flash.position = indicator.global_position
	$Flash.scale = Vector2.ONE
	$Flash.modulate = Global.YELLOW if perfect_hit else Color.WHITE
	var tween := get_tree().create_tween().set_parallel(true)
	tween.tween_property($Flash, "modulate", Color.TRANSPARENT, 0.5)
	tween.tween_property($Flash, "scale", Vector2(2.0, 2.0), 0.5)
	var max_damage := Global.characters[char_id].get_strength() * 5
	var damage := max_damage
	if !perfect_hit:
		if indicator.position.x > 82.0:
			damage = int(damage * remap(indicator.position.x, 202.0, 94.0, 0.0, 0.8))
		else:
			damage = int(damage * remap(indicator.position.x, 64.0, 82.0, 0.0, 0.8))
	return damage
