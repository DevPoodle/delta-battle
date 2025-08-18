@tool
extends Spell
class_name BasicAttack

@export var damage_amount := 90:
	set(p_damage_amount):
		damage_amount = maxi(0, p_damage_amount)
@export var animation_code := Character.Animations.ACT

func _init() -> void:
	if Engine.is_editor_hint():
		title = "Magic"
		text = "  * %s used magic to attack %s."
		description = "Magical Attack."
		target = 1

func do_spell(p_from: Character, p_to: Node2D) -> void:
	if !(p_to is Monster):
		p_from.spell_finished.emit()
		return
	
	var to := p_to as Monster
	to.take_damage(p_from, damage_amount)
	p_from.do_animation(animation_code)
	Global.display_text.emit(text % [p_from.title, to.title], true)
	await Global.text_finished
	p_from.spell_finished.emit()
